# File Transfer Go - Home Assistant Add-on

![Logo][logo]

基于 WebRTC 技术的端到端文件传输服务，支持文件传输、文字传输和桌面共享功能。

[![Release][release-shield]][release] ![Project Stage][project-stage-shield] [![License][license-shield]](LICENSE)

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armv7 Architecture][armv7-shield]

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[license-shield]: https://img.shields.io/github/license/wuwweizn/wwzn-china.svg
[project-stage-shield]: https://img.shields.io/badge/project%20stage-production%20ready-brightgreen.svg
[release-shield]: https://img.shields.io/badge/version-1.0.0-blue.svg
[release]: https://github.com/wuwweizn/wwzn-china/releases

## 关于

File Transfer Go 是一个基于 Go 和 React 开发的文件传输服务，使用 WebRTC 技术实现端到端的安全传输。

特性：
- 🔒 端到端加密，数据不经过服务器
- 📁 支持文件传输
- 💬 支持文字传输  
- 🖥️ 支持桌面共享
- 🌐 Web 界面，易于使用
- 🔧 Docker 部署，简单快捷

## 安装

安装此加载项就像其他加载项一样简单：

1. 导航到 Home Assistant 中的 Supervisor 加载项商店
2. 添加此仓库: `https://github.com/wuwweizn/wwzn-china`
3. 查找 "File Transfer Go" 加载项并点击它
4. 点击 "安装" 按钮

## 配置

加载项配置：

```yaml
port: 8080
node_env: "production"
log_level: "info"