# UnblockNeteaseMusic Home Assistant 加载项

这是一个用于 Home Assistant 的 UnblockNeteaseMusic 加载项，可以解锁网易云音乐中的灰色歌曲。

## 📋 功能特点

- 🎵 解锁网易云音乐灰色/无版权歌曲
- 🎶 支持多种音源：酷我、酷狗、咪咕等
- 🔊 支持 FLAC 无损音质
- 🚀 支持多架构：amd64、aarch64、armv7
- 🐋 基于 Docker 容器化部署
- 🔧 简单易用的 Web 配置界面

## 🚀 安装方式

### 方法一：通过加载项商店安装

1. 在 Home Assistant 中，进入 **监控面板** → **加载项**
2. 点击右下角的 **加载项商店**
3. 点击右上角的三个点，选择 **仓库**
4. 添加仓库地址：`https://github.com/wuwweizn/wwzn-china`
5. 在商店中找到 **UnblockNeteaseMusic** 并安装

### 方法二：手动安装

1. 在 Home Assistant 的 `/addons/` 目录中创建 `unblock-netease-music` 文件夹
2. 将所有配置文件复制到该文件夹中
3. 重启 Home Assistant
4. 在加载项页面找到并安装

## ⚙️ 配置选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `port` | 整数 | `8080` | HTTP 服务监听端口 |
| `host` | 字符串 | `"0.0.0.0"` | 监听地址 |
| `source_order` | 字符串 | `"kuwo kugou migu"` | 音源优先级顺序 |
| `enable_flac` | 布尔值 | `false` | 启用 FLAC 无损音质 |
| `enable_local_vip` | 布尔值 | `false` | 启用本地 VIP 功能 |
| `search_limit` | 整数 | `3` | 搜索结果限制数量 |
| `log_level` | 列表 | `"info"` | 日志级别：debug/info/warn/error |
| `strict` | 布尔值 | `false` | 严格模式（可选） |
| `endpoint` | URL | - | 自定义 API 端点（可选） |
| `proxy_only_netease_music` | 布尔值 | `false` | 仅代理网易云音乐流量 |

## 🎯 使用方法

### 1. 基本配置

安装并启动加载项后，服务将在指定端口（默认 8080）上运行。

### 2. 客户端配置

#### Windows 客户端
1. 打开网易云音乐设置
2. 找到代理设置
3. 设置 HTTP 代理：`<Home Assistant IP>:8080`

#### 手机客户端
1. 连接到同一 WiFi 网络
2. 设置 WiFi 代理为：`<Home Assistant IP>:8080`

### 3. 验证服务

访问 `http://<Home Assistant IP>:8080` 应该能看到服务状态页面。

## 🔧 高级配置示例

### 启用无损音质
```yaml
port: 8080
host: "0.0.0.0"
source_order: "kuwo kugou migu"
enable_flac: true
enable_local_vip: true
search_limit: 5
log_level: "info"
```

### 仅代理网易云音乐
```yaml
port: 8080
host: "0.0.0.0"
source_order: "kuwo kugou migu"
enable_flac: false
enable_local_vip: false
search_limit: 3
log_level: "warn"
proxy_only_netease_music: true
```

## 📊 支持的音源

- **kuwo**: 酷我音乐
- **kugou**: 酷狗音乐
- **migu**: 咪咕音乐
- **joox**: JOOX音乐（部分地区）
- **youtube**: YouTube Music（需要良好的网络环境）

> 💡 **提示**: 建议将网络环境较好的音源放在前面，以获得更好的使用体验。

## 🐛 故障排除

### 1. 服务无法启动
- 检查端口是否被占用
- 查看加载项日志获取错误信息
- 确认网络连接正常

### 2. 无法解锁歌曲
- 检查音源配置是否正确
- 尝试调整音源优先级
- 检查网络连接到各音源的可达性

### 3. 音质问题
- 启用 FLAC 支持获得无损音质
- 调整搜索限制数量
- 检查音源的音质支持情况

### 4. 网络连接问题
```bash
# 在加载项终端中测试连接
wget -q --spider --timeout=10 https://music.163.com/
```

## 📝 更新日志

### v1.0.0
- 初始版本发布
- 支持多架构构建
- 集成 Home Assistant 加载项系统
- 提供完整的配置选项

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目！

## 📄 许可证

本项目基于原始 [UnblockNeteaseMusic](https://github.com/nondanee/UnblockNeteaseMusic) 项目构建，遵循相同的开源许可证。

## ⚠️ 免责声明

本项目仅供学习和研究使用，请遵守相关法律法规和服务条款。使用本软件产生的任何后果由用户自行承担。

## 🔗 相关链接

- [原始项目](https://github.com/nondanee/UnblockNeteaseMusic)
- [Home Assistant](https://www.home-assistant.io/)
- [加载项开发文档](https://developers.home-assistant.io/docs/add-ons/)