# UnblockNeteaseMusic Enhanced - Home Assistant 加载项

这是基于 **UnblockNeteaseMusic/server** (重构增强版) 的 Home Assistant 加载项，相比原版具有更好的稳定性和兼容性。

## 📋 主要特点

- 🎵 解锁网易云音乐灰色/无版权歌曲
- 🔥 **基于增强版 UnblockNeteaseMusic/server** - 更稳定
- 🎶 支持多种音源：酷我、酷狗、咪咕等
- 🚀 支持多架构：amd64、aarch64、armv7
- 📦 使用 NPM 包 `@unblockneteasemusic/server`
- 🛠️ 简单易用的 Web 配置界面

## 🆚 与原版的区别

| 特性 | 原版 nondanee/UnblockNeteaseMusic | 增强版 UnblockNeteaseMusic/server |
|------|-----------------------------------|-----------------------------------|
| **稳定性** | 较旧，可能有网络问题 | **重构增强，更稳定** |
| **维护状态** | 更新较少 | **持续维护更新** |
| **安装方式** | Git克隆源码 | **NPM包安装** |
| **配置格式** | 空格分隔音源 | **冒号分隔音源** |
| **兼容性** | 部分环境有问题 | **更好的兼容性** |

## 🚀 安装方式

### 通过加载项商店安装

1. 在 Home Assistant 中，进入 **监控面板** → **加载项**
2. 点击右下角的 **加载项商店**
3. 点击右上角的三个点，选择 **仓库**
4. 添加仓库地址：`https://github.com/wuwweizn/wwzn-china`
5. 在商店中找到 **UnblockNeteaseMusic Enhanced** 并安装

## ⚙️ 配置选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `port` | 整数 | `8080` | HTTP 服务监听端口 |
| `sources` | 字符串 | `"kuwo:kugou:migu"` | 音源列表，用冒号分隔 |
| `strict` | 布尔值 | `false` | 严格模式 |
| `log_level` | 列表 | `"info"` | 日志级别 |

## 🎯 推荐配置

### 标准配置
```yaml
port: 8080
sources: "kuwo:kugou:migu"
strict: false
log_level: "info"
```

### 高质量音源优先
```yaml
port: 8080
sources: "migu:kuwo:kugou"
strict: false
log_level: "info"
```

### 调试模式
```yaml
port: 8080
sources: "kuwo:kugou:migu"
strict: false
log_level: "debug"
```

## 🎵 支持的音源

- **kuwo** - 酷我音乐
- **kugou** - 酷狗音乐  
- **migu** - 咪咕音乐
- **joox** - JOOX音乐（部分地区）
- **youtube** - YouTube Music（需要良好网络）

> **注意**: 音源使用**冒号(:)**分隔，如 `kuwo:kugou:migu`

## 🔧 使用方法

### 1. 配置加载项
在Home Assistant加载项配置页面设置：
```
port: 8080
sources: kuwo:kugou:migu
strict: false
log_level: info
```

### 2. 客户端配置

#### Windows/Mac 网易云客户端
1. 打开网易云音乐设置
2. 找到代理设置
3. 设置 HTTP 代理：`<Home Assistant IP>:8080`

#### 手机客户端
1. 连接到同一 WiFi 网络
2. 设置 WiFi 代理为：`<Home Assistant IP>:8080`

#### 路由器配置
在路由器中设置HTTP代理为Home Assistant地址，可以让所有设备自动使用。

## 🐛 故障排除

### 1. 服务无法启动
- 检查端口是否被占用
- 查看加载项日志获取错误信息

### 2. 无法解锁歌曲
- 尝试调整音源顺序
- 检查网络连接
- 确认代理设置正确

### 3. 网络连接问题
- 确保Home Assistant能访问外网
- 检查防火墙设置
- 尝试更换DNS服务器

## 📊 与istoreos测试结果对比

根据您的测试，此增强版本应该具有：
- ✅ 更好的网络稳定性
- ✅ 更少的JSON解析错误
- ✅ 更可靠的音源连接
- ✅ 更好的错误处理

## 📝 更新日志

### v2.0.0
- 基于 UnblockNeteaseMusic/server 增强版本
- 使用 NPM 包 @unblockneteasemusic/server
- 改进网络稳定性和错误处理
- 修正音源配置格式（冒号分隔）
- 优化启动脚本和日志输出

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

基于 [UnblockNeteaseMusic/server](https://github.com/UnblockNeteaseMusic/server) 项目构建。

## 🔗 相关链接

- [UnblockNeteaseMusic/server](https://github.com/UnblockNeteaseMusic/server) - 增强版核心项目
- [NPM包](https://www.npmjs.com/package/@unblockneteasemusic/server) - @unblockneteasemusic/server
- [Home Assistant](https://www.home-assistant.io/) - 智能家居平台

## ⚠️ 免责声明

本项目仅供学习和研究使用，请遵守相关法律法规和服务条款。使用本软件产生的任何后果由用户自行承担。