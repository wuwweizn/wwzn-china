# Home Assistant Add-on: Scrypted

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

Scrypted 是一个高性能的家庭视频集成和自动化平台，具有智能检测功能。

## 关于

Scrypted 提供以下功能：

- 🎥 **高性能视频处理**: 硬件加速转码和流媒体
- 🏠 **智能家居集成**: 原生支持 HomeKit、Google Home、Alexa
- 🎯 **AI 智能检测**: 物体检测、面部识别、车牌识别
- 📱 **移动应用**: iOS 和 Android 应用支持
- 🔧 **插件生态**: 丰富的插件系统
- 💾 **本地 NVR**: 完全本地化的网络视频录像功能
- 🎮 **游戏流媒体**: 支持游戏控制台流媒体

## 特色

- **内置 Home Assistant 集成**: 自动安装 `@scrypted/homeassistant` 插件
- **嵌入式界面**: 通过 ingress 直接在 HA 界面中显示
- **硬件加速支持**: 支持多种硬件加速设备
- **完整设备访问**: GPU、USB、串口等设备完全支持

## 安装

1. 添加此仓库到您的 Home Assistant 加载项商店
2. 搜索 "Scrypted" 加载项并点击安装
3. 启动加载项
4. 点击 "打开 Web UI" 或从侧边栏访问 Scrypted

## 配置

此加载项使用预配置设置，无需额外配置即可开始使用。

### 自动配置

- **Home Assistant 插件**: 自动安装和配置
- **数据存储**: `/data/scrypted_data`
- **NVR 存储**: `/data/scrypted_nvr` 
- **管理地址**: 自动配置为 Home Assistant 内部地址

## 使用方法

1. 启动加载项后，点击 "打开 Web UI"
2. 完成 Scrypted 的初始设置向导
3. 添加摄像头和其他设备
4. 配置所需的集成服务
5. 在 Home Assistant 中查看和管理设备

## 硬件支持

该加载项支持以下硬件加速：

- **Intel**: Quick Sync Video (QSV)
- **NVIDIA**: CUDA 和 NVENC/NVDEC
- **AMD**: VAAPI
- **Raspberry Pi**: 硬件视频编解码
- **Google Coral**: TPU 加速推理

## 网络

- **端口**: 11080 (自动通过 ingress 处理)
- **网络模式**: Host 网络模式，确保最佳性能
- **发现**: 自动发现局域网设备

## 数据管理

### 备份排除

以下目录会被自动排除在备份之外以节省空间：
- 服务器临时文件
- NVR 录像文件  
- 插件缓存文件

## 故障排除

### 常见问题

**Q: 无法访问摄像头**
A: 确认摄像头在同一网络，检查防火墙设置

**Q: 硬件加速不工作**
A: 检查主机是否有对应的硬件设备和驱动

**Q: HomeKit 配对失败**
A: 确保没有端口冲突，重启加载项重试

### 获取帮助

- [官方文档](https://docs.scrypted.app)
- [GitHub Issues](https://github.com/koush/scrypted/issues)
- [Discord 社区](https://discord.gg/DcFzmBHYGq)
- [Reddit 社区](https://reddit.com/r/scrypted)

## 版本历史

查看 [CHANGELOG.md](CHANGELOG.md) 获取详细的更新历史。

## 许可证

本加载项基于官方 Scrypted 项目。更多信息请参考 [Apache License 2.0](https://github.com/koush/scrypted/blob/main/LICENSE)。

---

![Scrypted](https://docs.scrypted.app/img/logo.svg)

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg