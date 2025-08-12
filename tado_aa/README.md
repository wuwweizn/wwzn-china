＃家庭助理社区附加组件：tado自动辅助和开窗检测
![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield]
![Project Maintenance][maintenance-shield]

Tado Auto-Assist for Geofencing and Open Window Detection for Home Assistant OS

＃＃ 关于

使用Tado应用程序设置的设置，该脚本会根据您的存在（到达或离开）自动调节房屋中的温度。它还在tado trv检测到打开窗口的任何房间中关闭加热（激活打开窗口模式）。

＃＃ 安装

[![FaserF Home Assistant Add-ons](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FFaserF%2Fhassio-addons)

此附加组件的安装很简单，类似于安装任何其他自定义家庭助手附加组件。
只需单击上面的链接或手动将此存储库添加到您的家庭助理附加存储库中：<https://github.com/faserf/hassio-addons>

＃＃ 配置

示例附加配置：

```yaml
username: my@email.com
password: mySecretPassword
minTemp: 5       # Optional – Minimum temperature to set
maxTemp: 25      # Optional – Maximum temperature to set
```

> **注意**：_这只是一个例子。请使用自己的凭据和所需的温度设置。

###选项：`username`

定义您的tado用户名（通常是您的电子邮件地址）。

＃＃＃ 选项: `password`

定义您的tado密码。

＃＃＃ 选项：`minTemp`

选填的。定义tado不在时应设定的最低温度。

＃＃＃ 选项: `maxTemp`

选填的。定义返回家园时Tado应设定的最高温度。

＃＃ 支持

有问题或问题吗？
如果您遇到任何问题或有建议，您可以[在GitHub上打开问题] [issue]。

⚠️ **Please note:** This add-on has only been tested on `armv7` (Raspberry Pi 4).

##积分

This add-on is based on the work of [adrianslabu], who created the original Python script:
➡️ <https://github.com/adrianslabu/tado_aa>

The Home Assistant add-on wrapper was created and is maintained by [FaserF].

[maintenance-shield]: https://img.shields.io/maintenance/yes/2025.svg
[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[FaserF]: https://github.com/FaserF/
[issue]: https://github.com/FaserF/hassio-addons/issues
[adrianslabu]: https://github.com/adrianslabu
