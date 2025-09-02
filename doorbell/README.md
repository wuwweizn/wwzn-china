# Home Assistant 插件：Hikvision 门铃

<p align="center">
   <a href="https://img.shields.io/badge/amd64-yes-green.svg">
      <img alt="Supports amd64 Architecture" src="https://img.shields.io/badge/amd64-yes-green.svg">
   </a>
   <a href="https://img.shields.io/badge/aarch64-yes-green.svg">
      <img alt="Supports aarch64 Architecture" src="https://img.shields.io/badge/aarch64-yes-green.svg">
   </a>
   <a href="https://img.shields.io/badge/i386-yes-green.svg">
      <img alt="Supports i386 Architecture" src="https://img.shields.io/badge/i386-yes-green.svg">
   </a>
</p>

将你的 Hikvision IP 门铃接入 Home Assistant，以便接收事件（如动作检测或来电）并发送命令（如打开门铃继电器连接的门或拒绝来电）。

**注意**：这是插件的稳定版本。
如果有疑问、想反馈或报告问题，请访问 [GitHub Issues 页面](https://github.com/pergolafabio/Hikvision-Addons/issues) 并留言！

---

## 功能

* 捕获门铃**事件**：*门铃响* / *动作检测* / *门已解锁* / *防拆报警*
* **开门**：控制门铃连接的门（适用于端口 80 被阻塞、无法使用 ISAPI 的老设备）
* 远程操作，如**接听**/**拒绝**来电、**挂断**

  * 可用于 Home Assistant 自动化。例如，当 Zigbee 门传感器检测到门被打开时，可停止室内机和 Hik-Connect 设备的响铃。
* **重启**门铃
* 远程场景支持，如 **atHome**/**goOut**/**goToBed**/**custom**

---

### 示例

下面是一个包含两个门铃、室内机和室外机的示例设置：

<p align="center">
   <img src="https://raw.githubusercontent.com/pergolafabio/Hikvision-Addons/dev/hikvision-doorbell/assets/docs_sensors.png" width="500px">
</p>

请务必阅读完整文档！[Readme](DOCS.md)

---

## 快速开始

**注意**：**Hikvision 门铃** 需要 MQTT Broker 才能正常工作。
请参考插件的 **Documentation** 选项卡，了解如何配置官方 **Mosquitto 插件**。

**注意**：使用此稳定版本时，需要在 Home Assistant 个人资料中启用 **高级模式**：

* 点击左下角用户名
* 滚动到页面底部，切换 **高级模式**

<p align="center">
<img src="https://user-images.githubusercontent.com/4510647/221361317-a9076a72-9762-4320-8302-24414e6019f2.png" width="600">
</p>

* 点击下方按钮，可在 Home Assistant 中自动打开插件界面：

<p align="center">
   <a href="https://my.home-assistant.io/redirect/supervisor_addon/?addon=aff2db71_hikvision_doorbell_beta&repository_url=https%3A%2F%2Fgithub.com%2Fpergolafabio%2FHikvision-Addons" target="_blank">
      <img src="https://my.home-assistant.io/badges/supervisor_addon.svg" alt="Open your Home Assistant instance and show the dashboard of a Supervisor add-on." />
   </a>
</p>

* 如果遇到问题，可手动操作：

  1. 打开 Home Assistant 界面，导航至 `Settings` -> `Add-ons` -> `Add-on store` -> `Repositories`（右上角）
  2. 在输入框中粘贴 URL：`https://github.com/pergolafabio/Hikvision-Addons`
  3. 点击 **ADD** 确认
  4. 在插件商店中找到 **Hikvision Doorbell (Beta)** 并安装
  5. 查看插件 **Documentation** 选项卡，了解如何配置以及在 Home Assistant 中集成

完整文档也可在线浏览：[Github 仓库](DOCS.md)

---

## 支持设备

以下设备经其他 HA 用户验证可用。
如果你的设备未在列表中，也可提交 Issue 申请支持。

* DS-KV8413
* DS-KD8003
* DS-KV8113
* DS-KV8213
* DS-KV6113
* DS-K1T34X
* DS-K1T67X
* DS-K1T670M
* DS-KB8113
* DS-KV9503（无来电事件）
* 其他经过用户验证的品牌重命名设备，如 Metzler 的 VDM10
* …
* DS-KV8102-IM（第一代不支持，仅开锁功能有效）
* DS-K1T502DBFWX（完全不支持）
* DS-HD1 和 DS-HD2 可能不支持？不支持 ISAPI？

请务必阅读完整文档！[Readme](DOCS.md)

---

## 其他资源

* [Home Assistant 社区论坛](https://community.home-assistant.io/t/add-on-hikvision-doorbell-integration/532796)

---

## 贡献

这是一个活跃的开源项目，欢迎任何想使用或贡献代码的人参与！
详细信息请查看 [documentation 文件夹](docs/)

### 贡献者

<a href="https://github.com/pergolafabio/Hikvision-Addons/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=pergolafabio/Hikvision-Addons" />
</a>

使用 [contrib.rocks](https://contrib.rocks) 制作

---

## 捐赠

喜欢我的工作？你可以随时 [捐赠我](https://paypal.me/pergolafabio)。

---

## 致谢

该插件最初灵感来源于 [此脚本](https://github.com/laszlojakab/hikvision-intercom-python-demo)。


