# Home Assistant 社区加载项: Nginx Proxy Manager

这个加载项可以让你轻松地将传入连接转发到任何地方，
支持免费 SSL，而无需深入了解 Nginx 或 Let’s Encrypt 的使用细节。

你可以把域名直接转发到你的 Home Assistant、加载项，
或者在家中或其他地方运行的网站 —— 全部都可以通过一个简单、强大的界面完成。

想要给网站添加用户名/密码保护吗？这个插件也能做到！
只需启用认证，并创建允许访问该应用的用户/密码列表即可。

对于高级用户，你可以通过提供额外的 Nginx 指令，自定义每个主机的代理行为。

## 安装

安装过程非常简单，与安装其他 Home Assistant 加载项没有区别：

1. 点击下面的 Home Assistant 按钮，在你的 Home Assistant 实例中打开该加载项。

   [![Open this add-on in your Home Assistant instance.][addon-badge]][addon]

2. 点击 “Install” 按钮安装加载项。
3. 启动 “Nginx Proxy Manager” 加载项。
4. 查看 日志，确认加载项启动正常。
5. 点击 “OPEN WEB UI” 按钮登录网页界面：
    邮箱：admin@example.com
    密码：changeme
6. 将路由器的端口 443（可选 80）转发到你的 Home Assistant 主机。
7. 完成设置，享受加载项功能！

## 配置

这个加载项 不提供任何额外配置，所有操作都在网页界面完成。

## 更新日志 & 版本发布

This repository keeps a change log using [GitHub's releases][releases]
functionality.

Releases are based on [Semantic Versioning][semver], and use the format
of `MAJOR.MINOR.PATCH`. In a nutshell, the version will be incremented
based on the following:

- `MAJOR`: Incompatible or major changes.
- `MINOR`: Backwards-compatible new features and enhancements.
- `PATCH`: Backwards-compatible bugfixes and package updates.

## 支持

有问题？

你可以通过以下方式获取帮助：

- The [Home Assistant Community Add-ons Discord chat server][discord] for add-on
  support and feature requests.
- The [Home Assistant Discord chat server][discord-ha] for general Home
  Assistant discussions and questions.
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

You could also [open an issue here][issue] GitHub.

## 作者 & 贡献者

The original setup of this repository is by [Franck Nijhof][frenck].

For a full list of all authors and contributors,
check [the contributor's page][contributors].

## 许可

MIT 许可证

Copyright (c) 2019-2025 Franck Nijhof

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

[addon-badge]: https://my.home-assistant.io/badges/supervisor_addon.svg
[addon]: https://my.home-assistant.io/redirect/supervisor_addon/?addon=a0d7b954_nginxproxymanager&repository_url=https%3A%2F%2Fgithub.com%2Fhassio-addons%2Frepository
[contributors]: https://github.com/hassio-addons/addon-nginx-proxy-manager/graphs/contributors
[discord-ha]: https://discord.gg/c5DvZ4e
[discord]: https://discord.me/hassioaddons
[forum]: https://community.home-assistant.io/t/home-assistant-community-add-on-nginx-proxy-manager/111830?u=frenck
[frenck]: https://github.com/frenck
[issue]: https://github.com/hassio-addons/addon-nginx-proxy-manager/issues
[reddit]: https://reddit.com/r/homeassistant
[releases]: https://github.com/hassio-addons/addon-nginx-proxy-manager/releases
[semver]: https://semver.org/spec/v2.0.0.html
