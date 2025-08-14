# Lucky Home Assistant 加载项

## 简介

Lucky 是一个功能强大的网络工具，专为软硬路由设计的公网神器。支持 IPv6/IPv4 端口转发、反向代理、DDNS、内网穿透、网络唤醒等多种功能。

## 主要功能

### 🌐 端口转发
- 支持公网 IPv6 转内网 IPv4 的 TCP/UDP 端口转发
- 界面化管理转发规则
- 支持黑白名单安全模式
- 实时访问日志记录

### 🔄 动态域名 (DDNS)
- 支持多个DNS服务商（阿里云、腾讯云、华为云、Cloudflare等）
- 自定义回调支持
- IPv4/IPv6双栈支持
- 自动检测IP变化

### 🌍 Web服务
- 反向代理和重定向
- HTTP基本认证
- IP黑白名单
- UserAgent过滤

### 🔧 内网穿透
- STUN内网穿透
- 无需公网IPv4地址
- 适合国内运营商级NAT网络

### 🔐 证书管理
- ACME自动证书申请和续签
- 支持多个证书服务商
- Let's Encrypt支持

### 📁 网络存储
- WebDAV服务
- FTP服务  
- FileBrowser文件管理器
- 阿里云盘挂载（已停用）

## 安装说明

### 1. 添加仓库
在Home Assistant的加载项商店中，点击右上角菜单，选择"仓库"，添加以下URL：

```
https://github.com/wuwweizn/wwzn-china
```

### 2. 安装加载项
1. 在加载项商店中找到"Lucky"
2. 点击安装
3. 等待安装完成

### 3. 配置加载项
在配置页面中，你可以设置：

- **web_port**: Web管理界面端口 (默认: 16601)
- **admin_username**: 管理员用户名 (默认: 666)
- **admin_password**: 管理员密码 (默认: 666)
- **log_level**: 日志级别 (debug/info/warn/error)

### 4. 启动加载项
1. 启用"开机自启"
2. 点击"启动"
3. 检查日志确认启动成功

## 访问界面

启动成功后，可以通过以下方式访问Lucky管理界面：

- 直接访问: `http://YOUR_HA_IP:16601`
- 或点击加载项页面的"打开Web UI"按钮

默认登录信息：
- 用户名: 666
- 密码: 666

⚠️ **重要**: 首次登录后请立即修改默认密码！

## 网络要求

Lucky需要特殊的网络权限来实现其功能：

- **host_network**: 使用主机网络模式，支持IPv4/IPv6
- **privileged**: 网络管理权限
- **devices**: 访问网络设备

这些权限对于端口转发、内网穿透等功能是必需的。

## 常见问题

### Q: 为什么需要主机网络模式？
A: Lucky的端口转发和内网穿透功能需要直接操作网络接口，主机网络模式可以提供完整的网络访问权限。

### Q: 如何备份配置？
A: 所有配置文件都保存在Home Assistant的配置目录中，会随着HA的备份自动备份。

### Q: 支持哪些架构？
A: 支持 amd64、arm64、armv7、armhf、i386 等主流架构。

### Q: 如何更新？
A: 在加载项页面点击"更新"按钮，或者重新安装最新版本。

## 支持

- 官方文档: https://lucky666.cn
- 项目主页: https://github.com/gdy666/lucky
- 问题反馈: https://github.com/wuwweizn/wwzn-china/issues

## 许可证

本加载项基于原始Lucky项目，遵循其开源协议。

## 致谢

感谢 [gdy666](https://github.com/gdy666) 开发的优秀的Lucky项目。