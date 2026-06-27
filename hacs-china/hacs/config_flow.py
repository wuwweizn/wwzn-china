"""Adds config flow for HACS."""

from __future__ import annotations

import aiohttp
import asyncio
from contextlib import suppress
from typing import TYPE_CHECKING

from aiogithubapi import (
    GitHubDeviceAPI,
    GitHubException,
    GitHubLoginDeviceModel,
    GitHubLoginOauthModel,
)
from aiogithubapi.common.const import OAUTH_USER_LOGIN
from awesomeversion import AwesomeVersion
from homeassistant.config_entries import ConfigFlow, OptionsFlow
from homeassistant.const import __version__ as HAVERSION
from homeassistant.core import callback
from homeassistant.data_entry_flow import UnknownFlow
from homeassistant.helpers import aiohttp_client
from homeassistant.helpers.selector import TextSelector, TextSelectorConfig, TextSelectorType
from homeassistant.loader import async_get_integration
import voluptuous as vol

from .base import HacsBase
from .const import CLIENT_ID, DOMAIN, LOCALE, MINIMUM_HA_VERSION, BASE_API_URL
from .utils.configuration_schema import (
    APPDAEMON,
    COUNTRY,
    SIDEPANEL_ICON,
    SIDEPANEL_TITLE,
    GITHUB_APIS,
)
from .utils.logger import LOGGER

if TYPE_CHECKING:
    from homeassistant.core import HomeAssistant


class HacsFlowHandler(ConfigFlow, domain=DOMAIN):
    """Config flow for HACS."""

    VERSION = 1

    hass: HomeAssistant
    activation_task: asyncio.Task | None = None
    device: GitHubDeviceAPI | None = None

    _registration: GitHubLoginDeviceModel | None = None
    _activation: GitHubLoginOauthModel | None = None
    _reauth: bool = False

    def __init__(self) -> None:
        """Initialize."""
        self._errors = {}
        self._user_input = {}

    async def async_step_user(self, user_input):
        """Handle a flow initialized by the user."""
        self._errors = {}
        if self._async_current_entries():
            return self.async_abort(reason="single_instance_allowed")
        if self.hass.data.get(DOMAIN):
            return self.async_abort(reason="single_instance_allowed")

        if user_input:
            if [x for x in user_input if x.startswith("acc_") and not user_input[x]]:
                self._errors["base"] = "acc"
                return await self._show_config_form(user_input)

            self._user_input = user_input
            if not user_input.get('use_shared'):
                return await self.async_step_device(user_input)
            elif await self.async_get_shard_token():
                return await self.async_step_device_done(user_input)
            else:
                self._errors['base'] = 'get_shared'
                return await self._show_config_form(user_input)

        # Initial form
        return await self._show_config_form(user_input)

    async def async_step_device(self, _user_input):
        """Handle device steps."""

        async def _wait_for_activation() -> None:
            try:
                response = await self.device.activation(device_code=self._registration.device_code)
                self._activation = response.data
            finally:

                async def _progress():
                    with suppress(UnknownFlow):
                        await self.hass.config_entries.flow.async_configure(flow_id=self.flow_id)

        if not self.device:
            integration = await async_get_integration(self.hass, DOMAIN)
            # 使用国内 DNS 服务器，绕过 DNS 污染（github.com 被解析到 127.0.0.1 的问题）
            try:
                from aiohttp.resolver import AsyncResolver
                _resolver = AsyncResolver(nameservers=["114.114.114.114", "223.5.5.5", "8.8.8.8"])
                _connector = aiohttp.TCPConnector(resolver=_resolver, ssl=True)
                _github_session = aiohttp.ClientSession(connector=_connector)
            except Exception:
                _github_session = aiohttp_client.async_get_clientsession(self.hass)
            self.device = GitHubDeviceAPI(
                client_id=CLIENT_ID,
                session=_github_session,
                **{"client_name": f"HACS/{integration.version}"},
            )
            try:
                response = await self.device.register()
                self._registration = response.data
            except GitHubException as exception:
                LOGGER.exception(exception)
                return self.async_abort(reason="could_not_register")

        if self.activation_task is None:
            self.activation_task = self.hass.async_create_task(_wait_for_activation())

        if self.activation_task.done():
            if (exception := self.activation_task.exception()) is not None:
                LOGGER.exception(exception)
                return self.async_show_progress_done(next_step_id="could_not_register")
            return self.async_show_progress_done(next_step_id="device_done")

        show_progress_kwargs = {
            "step_id": "device",
            "progress_action": "wait_for_device",
            "description_placeholders": {
                "url": OAUTH_USER_LOGIN,
                "code": self._registration.user_code,
            },
            "progress_task": self.activation_task,
        }
        return self.async_show_progress(**show_progress_kwargs)

    async def async_step_manual_token(self, user_input):
        """手动输入 GitHub PAT，作为共享令牌不可用时的备用方案。"""
        errors = {}
        if user_input is not None:
            token = user_input.get("token", "").strip()
            if not token:
                errors["base"] = "auth"
            else:
                self._activation = GitHubLoginOauthModel({"access_token": token})
                return await self.async_step_device_done(self._user_input)

        return self.async_show_form(
            step_id="manual_token",
            data_schema=vol.Schema({vol.Required("token"): str}),
            errors=errors,
        )

    async def _show_config_form(self, user_input):
        """Show the configuration form to edit location data."""

        if not user_input:
            user_input = {}

        if AwesomeVersion(HAVERSION) < MINIMUM_HA_VERSION:
            return self.async_abort(
                reason="min_ha_version",
                description_placeholders={"version": MINIMUM_HA_VERSION},
            )
        return self.async_show_form(
            step_id="user",
            data_schema=vol.Schema(
                {
                    vol.Optional("use_shared", default=user_input.get("use_shared", True)): bool,
                    vol.Optional("tokenhub_url", default=user_input.get("tokenhub_url", "")): TextSelector(TextSelectorConfig(type=TextSelectorType.URL)),
                    vol.Required("acc_logs", default=user_input.get("acc_logs", False)): bool,
                    vol.Required("acc_addons", default=user_input.get("acc_addons", False)): bool,
                    vol.Required(
                        "acc_untested", default=user_input.get("acc_untested", False)
                    ): bool,
                    vol.Required("acc_disable", default=user_input.get("acc_disable", False)): bool,
                }
            ),
            errors=self._errors,
        )

    async def async_step_device_done(self, user_input: dict[str, bool] | None = None):
        """Handle device steps"""
        if self._reauth:
            existing_entry = self.hass.config_entries.async_get_entry(self.context["entry_id"])
            self.hass.config_entries.async_update_entry(
                existing_entry, data={**existing_entry.data, "token": self._activation.access_token}
            )
            await self.hass.config_entries.async_reload(existing_entry.entry_id)
            return self.async_abort(reason="reauth_successful")

        return self.async_create_entry(
            title="",
            data={
                "token": self._activation.access_token,
            },
            options={
                "experimental": True,
                "use_shared": self._user_input.get('use_shared', False),
                "tokenhub_url": self._user_input.get('tokenhub_url', ''),
            },
        )

    async def async_step_could_not_register(self, _user_input=None):
        """Handle issues that need transition await from progress step."""
        return self.async_abort(reason="could_not_register")

    async def async_step_reauth(self, _user_input=None):
        """Perform reauth upon an API authentication error."""
        return await self.async_step_reauth_confirm()

    async def async_step_reauth_confirm(self, user_input=None):
        """Dialog that informs the user that reauth is required."""
        if user_input is None:
            return self.async_show_form(
                step_id="reauth_confirm",
                data_schema=vol.Schema({}),
            )
        self._reauth = True
        return await self.async_step_manual_token(None)

    @staticmethod
    @callback
    def async_get_options_flow(config_entry):
        return HacsOptionsFlowHandler(config_entry)

    async def async_get_shard_token(self):
        # 1. 首次配置时从表单输入读取；重新认证时从已有 entry options 读取
        custom_hub = self._user_input.get("tokenhub_url", "").rstrip("/")
        if not custom_hub:
            entry = next(iter(self.hass.config_entries.async_entries(DOMAIN)), None)
            custom_hub = entry.options.get("tokenhub_url", "").rstrip("/") if entry else ""
        endpoints = []
        if custom_hub:
            endpoints.append(f"{custom_hub}/api/token/get")
        endpoints.append("https://tokenhub.hacs.vip/api/token/get")

        integration = await async_get_integration(self.hass, DOMAIN)
        http = aiohttp_client.async_get_clientsession(self.hass)
        token = None
        for api in endpoints:
            for attempt in range(2):
                try:
                    LOGGER.debug("[SharedToken] Attempt %d: requesting %s", attempt + 1, api)
                    res = await http.get(
                        api,
                        timeout=aiohttp.ClientTimeout(total=15),
                        headers={'User-Agent': f'HACS China/{integration.version}'},
                    )
                    dat = await res.json(content_type=None)
                    token = dat.get('data', {}).get('token')
                    if token:
                        break
                    LOGGER.warning(
                        "[SharedToken] Attempt %d: token empty, server error: %s",
                        attempt + 1, dat.get('error', dat),
                    )
                except Exception as err:
                    LOGGER.error("[SharedToken] Attempt %d failed: %s", attempt + 1, err)
                if attempt < 1:
                    await asyncio.sleep(2)
            if token:
                break

        if not token:
            return None
        self._activation = GitHubLoginOauthModel({'access_token': token})
        return token


class HacsOptionsFlowHandler(OptionsFlow):
    """HACS config flow options handler."""

    def __init__(self, config_entry):
        """Initialize HACS options flow."""
        if AwesomeVersion(HAVERSION) < "2024.11.99":
            self.config_entry = config_entry

    async def async_step_init(self, _user_input=None):
        """Manage the options."""
        return await self.async_step_user()

    async def async_step_user(self, user_input=None):
        """Handle a flow initialized by the user."""
        hacs: HacsBase = self.hass.data.get(DOMAIN)
        if user_input is not None:
            if api := user_input.get('github_api_custom'):
                user_input['github_api_base'] = api
            return self.async_create_entry(title="", data={**user_input, "experimental": True})

        if hacs is None or hacs.configuration is None:
            return self.async_abort(reason="not_setup")

        if hacs.queue.has_pending_tasks:
            return self.async_abort(reason="pending_tasks")

        api_base = hacs.configuration.github_api_base or BASE_API_URL
        GITHUB_APIS.setdefault(api_base, f'{api_base} (自定义)')
        tokenhub_url = self.config_entry.options.get("tokenhub_url", "")
        schema = {
            vol.Optional(SIDEPANEL_TITLE, default=hacs.configuration.sidepanel_title): str,
            vol.Optional(SIDEPANEL_ICON, default=hacs.configuration.sidepanel_icon): str,
            vol.Optional(COUNTRY, default=hacs.configuration.country): vol.In(LOCALE),
            vol.Optional("github_api_base", default=api_base): vol.In(GITHUB_APIS),
            vol.Optional("github_api_custom", default=''): TextSelector(TextSelectorConfig(type=TextSelectorType.URL)),
            vol.Optional("tokenhub_url", default=tokenhub_url): TextSelector(TextSelectorConfig(type=TextSelectorType.URL)),
            vol.Optional(APPDAEMON, default=hacs.configuration.appdaemon): bool,
        }

        return self.async_show_form(step_id="user", data_schema=vol.Schema(schema))
