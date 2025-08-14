
# Home Assistant 插件：Zigbee2MQTT 代理

[![Docker Pulls](https://img.shields.io/docker/pulls/zigbee2mqtt/zigbee2mqtt-proxy-amd64.svg?style=flat-square\&logo=docker)](https://cloud.docker.com/u/zigbee2mqtt/repository/docker/dwelch2101/zigbee2mqtt-proxy-amd64)

⚠️ 该插件**不包含** Zigbee2MQTT ⚠️

该插件的作用是作为一个代理，连接到一个外部运行的 Zigbee2MQTT 实例。
这个插件的唯一目的，是在 Home Assistant 侧边栏中添加一个 Zigbee2MQTT 图标，点击后可以打开外部运行的 Zigbee2MQTT 前端界面。

## 配置选项

* `server`（必填）：这里填写 Zigbee2MQTT 前端运行的本地 URL，例如 `http://192.168.2.43:8080`。注意不要在末尾添加斜杠！
* `auth_token`（可选）：仅在你在 Zigbee2MQTT 配置中为前端设置了 `auth_token` 时使用。

---

如果你需要，我可以帮你把整个 README 完整翻译成中文，包括安装和使用说明，让中文用户更容易理解。你希望我帮你做吗？
