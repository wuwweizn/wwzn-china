# WebTunnel Home Assistant Add-on

WebTunnel 是一个强大的网络隧道工具，现在可以作为 Home Assistant 加载项使用。

## 功能特性

- 🚀 高性能网络隧道
- 🔒 安全的数据传输
- 🌐 支持多种协议
- 📊 实时状态监控
- 🎛️ 简单的配置管理
- 🏠 完全集成到 Home Assistant

## 支持的架构

该加载项支持以下架构：

- `amd64` / `x86_64`
- `aarch64` / `arm64`

## 安装

### 方法一：通过 Home Assistant 加载项商店

1. 在 Home Assistant 中导航到 **Supervisor** → **Add-on Store**
2. 点击右上角的菜单（三个点）→ **Repositories**
3. 添加此仓库：`https://github.com/wuwweizn/wwzn-china`
4. 找到 "WebTunnel" 加载项并点击安装

## 配置

### 基本配置

```网络
server_port: 9600
```

## 使用说明

1. **启动加载项**：
   - 安装完成后，点击 "启动" 按钮
   - 等待加载项完全启动（通常需要几秒钟）

2. **访问 Web 界面**：
   - 打开浏览器访问：`http://homeassistant.local:9600`
   - 或使用您的 Home Assistant IP：`http://YOUR_HA_IP:9600`

## 故障排除


### 常见问题

日志信息： /data/.webtunnel/config.json 不存在，无法和平台建立心跳。
影响范围: 1. 此问题会导致重启后无法恢复连接状态, 开机自启动服务失效。
               2. 无法在云控制台远程操作此终端。
解决方法: 在内网中打开 WebTunnel 客户端，退出用户再重新登录一次即可（Windows/macOS/Linux 客户端请在客户端界面上操作，
              Docker请在 http://docker安装主机的IP:9600 控制面板上操作）。
可能原因: 1. 删除了配置文件目录。
              2. 首次安装 WebTunnel 且没有登录过。
              3. 升级完 WebTunnel, 但没有将 WebTunnel 的配置文件路径指向之前版本的路径，导致用户配置文件找不到。

**Q: 加载项无法启动？**

A: 请检查：
- 端口 9600 是否被其他服务占用
- 查看加载项日志获取详细错误信息
- 确保您的系统架构受支持

**Q: 无法访问 Web 界面？**

A: 请确认：
- 加载项已完全启动
- 防火墙设置允许端口 9600
- 使用正确的 IP 地址和端口

**Q: 配置丢失？**

A: 配置文件存储在 Home Assistant 配置目录中，重新安装加载项不会丢失配置。

### 查看日志

在 Home Assistant 中：
1. 进入 **Supervisor** → **WebTunnel**
2. 点击 **日志** 标签
3. 查看详细的运行日志

### 贡献指南

欢迎提交问题和拉取请求！请确保：

1. 遵循现有的代码风格
2. 添加适当的测试
3. 更新文档（如需要）
4. 在拉取请求中描述您的更改

## 许可证

本项目采用 MIT 许可证。详见 [LICENSE](../LICENSE) 文件。

## 支持

如果您遇到问题或有建议，请：

1. 查看 [FAQ](#故障排除)
2. 搜索现有的 [Issues](https://github.com/wuwweizn/wwzn-china/issues)
3. 创建新的 Issue 并提供详细信息

## 更新日志

### v1.0.0 (2024-08-31)

- 🎉 初始发布
- ✅ 支持 amd64 和 aarch64 架构
- 🔧 基本配置选项
- 📱 Web 界面集成
- 🏠 Home Assistant 完全集成

---

**注意**: 这是一个社区维护的加载项，不隶属于官方 Home Assistant 项目。