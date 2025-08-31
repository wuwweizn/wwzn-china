# Home Assistant 社区加载项：Traccar

\[Traccar]\[traccar] 是一个现代的 GPS 追踪平台，现在可以作为 Hass.io 加载项运行，让你无需依赖云端即可运行 GPS 追踪软件。

Traccar 支持的协议和设备型号比市场上任何其他 GPS 追踪系统都多，直接通过 Hass.io 实例即可使用。你可以从低成本的国产设备到高端品牌选择 GPS 追踪器。

Traccar 还提供 Android 和 iOS 原生移动应用，可以在手机上进行追踪。同时，通过 Home Assistant 的 `traccar` 集成（从版本 0.83 开始引入），Traccar 的数据可以同步回 Home Assistant。

---

## 安装

安装此加载项非常简单，与其他 Home Assistant 加载项类似。

1. 确保你已经安装并运行了官方的 \[MariaDB 加载项]\[mariadb]。

2. 点击 Home Assistant 中的 “My button” 打开加载项页面。

   \[!\[在 Home Assistant 中打开加载项]\[addon-badge]]\[addon]

3. 点击 “Install” 按钮安装加载项。

4. 启动 “Traccar” 加载项。

5. 查看 “Traccar” 加载项日志，确保运行正常。

6. 点击 “OPEN WEB UI” 打开 Web 界面。

---

## 配置

**注意**：修改配置后请记得重启加载项。

示例加载项配置：

```yaml
log_level: info
ssl: true
certfile: fullchain.pem
keyfile: privkey.pem
```

**注意**：这是示例配置，请根据实际情况创建自己的配置，不要直接复制粘贴！

### 配置选项

#### `log_level`

控制加载项日志输出的详细程度。可选值：

* `trace`：显示所有细节，包括所有内部函数调用。
* `debug`：显示详细调试信息。
* `info`：正常（通常）信息事件。
* `warning`：非错误但异常事件。
* `error`：运行时错误，无需立即处理。
* `fatal`：严重错误，加载项无法使用。

> 每个级别会包含比它更严重的日志。例如 `debug` 会显示 `info` 日志。默认值是 `info`。

#### `ssl`

是否启用 Web 界面的 HTTPS。

* 设置为 `true`：启用
* 设置为 `false`：禁用

#### `certfile`

SSL 证书文件路径，必须存储在 `/ssl/` 下。

#### `keyfile`

SSL 私钥文件路径，必须存储在 `/ssl/` 下。

---

## 集成到 Home Assistant

Home Assistant 的 `traccar` 集成可以将 Traccar 中的所有资产作为设备同步到 Home Assistant。

在 Home Assistant 的 `configuration.yaml` 中添加：

```yaml
device_tracker:
  - platform: traccar
    host: localhost
    port: 18682
    username: TRACCAR_EMAIL_ADDRESS
    password: TRACCAR_PASSWORD
```

重启 Home Assistant。

---

## 启用更多协议

默认情况下，此加载项禁用了大部分 GPS 协议，以减少开放端口数量。

默认仅启用 OsmAnd 协议（Traccar App 使用）和 API。
如果需要更多协议，可在加载项配置文件夹中的 `traccar.xml` 中添加条目。
完整列表请见：[traccar.xml](https://github.com/hassio-addons/addon-traccar/blob/main/traccar/rootfs/etc/traccar/traccar.xml#L22)

设备使用的协议可参考 [Traccar 官方网站](https://www.traccar.org/devices/)。

---

## 更新日志 & 版本发布

本仓库使用 \[GitHub Releases]\[releases] 记录变更。
版本遵循 \[语义化版本]\[semver] 格式 `MAJOR.MINOR.PATCH`：

* `MAJOR`：不兼容或重大变更
* `MINOR`：向下兼容的新功能或增强
* `PATCH`：向下兼容的 bug 修复或更新

---

## 支持

如有问题，可通过以下方式获取帮助：

* \[Home Assistant 社区加载项 Discord 聊天服务器]\[discord]
* \[Home Assistant Discord 官方服务器]\[discord-ha]
* Home Assistant \[社区论坛]\[forum]
* Reddit 社区 \[/r/homeassistant]\[reddit]
* 或 \[在 GitHub 上提交 issue]\[issue]

---

## 作者与贡献者

原始仓库由 \[Franck Nijhof]\[frenck] 创建。
完整贡献者列表见：\[Contributors 页面]\[contributors]。

---

## 许可证

MIT License

版权所有 (c) 2018-2024 Franck Nijhof

允许免费使用、修改、合并、发布、分发、再授权或销售本软件及文档，但必须保留版权声明和许可声明。

软件按 “原样” 提供，不提供任何明示或暗示的保证，包括适销性或特定用途适用性。作者不对使用过程中产生的任何责任承担责任。

---

### 链接说明

* `[addon-badge]`: ![Supervisor Add-on Badge](https://my.home-assistant.io/badges/supervisor_addon.svg)
* `[addon]`: [在 Home Assistant 中打开 Add-on](https://my.home-assistant.io/redirect/supervisor_addon/?addon=a0d7b954_traccar&repository_url=https%3A%2F%2Fgithub.com%2Fhassio-addons%2Frepository)
* `[contributors]`: [贡献者列表](https://github.com/hassio-addons/addon-traccar/graphs/contributors)
* `[discord-ha]`: [Home Assistant Discord](https://discord.gg/c5DvZ4e)
* `[discord]`: [Add-ons Discord](https://discord.me/hassioaddons)
* `[forum]`: [社区论坛](https://community.home-assistant.io/t/home-assistant-community-add-on-traccar/81407?u=frenck)
* `[reddit]`: [Reddit /r/homeassistant](https://reddit.com/r/homeassistant)
* `[issue]`: [GitHub Issue](https://github.com/hassio-addons/addon-traccar/issues)
* `[releases]`: [GitHub Releases](https://github.com/hassio-addons/addon-traccar/releases)
* `[semver]`: [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
* `[traccar]`: [Traccar 官方网站](https://www.traccar.org)


