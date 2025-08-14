# Home Assistant 插件：Zigbee2MQTT Edge

[![Docker Pulls](https://img.shields.io/docker/pulls/zigbee2mqtt/zigbee2mqtt-edge-amd64.svg?style=flat-square\&logo=docker)](https://cloud.docker.com/u/zigbee2mqtt/repository/docker/dwelch2101/zigbee2mqtt-edge-amd64)

⚠️ 这是 Edge 版本（跟随 Zigbee2MQTT 的开发分支）⚠️

允许你在**不使用厂商网关或桥接设备**的情况下使用 Zigbee 设备。

它会桥接事件，并允许你通过 MQTT 控制你的 Zigbee 设备。这样，你就可以将 Zigbee 设备与任何智能家居系统集成。

更多详情请参阅文档标签页。

### 更新 Edge 插件

要更新 Edge 版本的插件，需要先卸载再重新安装插件。

⚠️ 请确保备份你的配置，因为该过程不会自动保存配置。

**步骤：**

1. 备份配置：**设置 → 插件 → Zigbee2MQTT Edge → 配置 → ⋮ → YAML 编辑**，将 **Options** 复制到安全位置
2. 卸载插件：**设置 → 插件 → Zigbee2MQTT Edge → 卸载**
3. 刷新仓库：**设置 → 插件 → 插件商店 → ⋮ → 检查更新**
4. 安装插件：**设置 → 插件 → 插件商店 → Zigbee2MQTT Edge → 安装**
5. 恢复配置：**设置 → 插件 → Zigbee2MQTT Edge → 配置 → ⋮ → YAML 编辑**，将第 1 步备份的配置粘贴回去

---

如果需要，我可以帮你把整个 README 中文化，包括安装和使用说明，让中文用户完全参考。你想让我做吗？
