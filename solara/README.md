# Solara Music Player - Home Assistant Add-on

这是将 [Solara](https://github.com/akudamatata/Solara) 音乐播放器集成到 Home Assistant 的加载项。

Solara 是一个极简风格的基于免费API的网页音乐播放器，支持跨站曲库检索、队列管理、动态歌词、多码率下载等功能。

## 🎵 功能特性

- 🔍 跨站曲库检索：一键切换数据源，支持分页浏览
- 📻 队列管理灵活：新增、删除、清空操作即时生效
- 🔁 丰富的播放模式：列表循环、单曲循环与随机播放
- 📱 移动端友好：全新竖屏布局匹配移动端手势
- 📝 动态歌词视图：逐行滚动高亮，当前行自动聚焦
- 📥 多码率下载：128K / 192K / 320K / FLAC 等品质
- 🎨 主题美学：内置亮/暗模式与玻璃拟态界面

## 🚀 安装步骤


### 1. 添加仓库到 Home Assistant

在 Home Assistant 中，进入 **设置** > **加载项** > **加载项商店** > 右上角三个点 > **仓库**

添加以下 URL：
```
https://github.com/wuwweizn/wwzn-china
```

### 2. 安装 Solara 加载项

在加载项商店中找到 "Solara Music Player"，点击安装。

### 3. 配置加载项

在加载项的 "配置" 选项卡中，你可以调整以下设置：
- **api_url**: API 后端地址（默认：https://music.gdstudio.xyz - GD音乐台官方API）
  - 可以使用你自己部署的 Cloudflare Pages 域名（如 https://music.miaowu086.online）
  - 或使用其他可用的 Solara API 后端
- **log_level**: 日志级别 (debug, info, warning, error)

**重要**: 修改 API URL 后需要重启加载项才能生效。

### 4. 启动加载项

点击 "启动" 按钮启动 Solara 音乐播放器。

### 5. 访问 Solara

- **方法1**: 点击加载项界面上的 "打开 Web UI" 按钮
- **方法2**: 通过侧边栏的 Solara Music 面板（如果启用了 Ingress）
- **方法3**: 直接访问 `http://homeassistant.local:3100`

## 📁 数据持久化

加载项会将数据保存在以下位置：
- `/config/solara` - 应用配置和自定义文件
- `/share/solara` - 共享文件
- `/media` - 媒体文件访问

## 🔧 配置说明

### 端口映射

- **3100**: Solara Music Player Web UI 端口

### 自定义配置

如果你想自定义 Solara 的配置（例如修改 API 接口地址），可以：

1. 将 `/config/solara` 目录中的文件复制出来
2. 根据需要修改 `index.html` 中的配置（约 1300 行附近的 `API.baseUrl`）
3. 重启加载项

## ⚠️ 重要说明

### API 后端配置

Solara 需要后端 API 来搜索和播放音乐。

**默认使用 GD音乐台官方API**：`https://music.gdstudio.xyz`（感谢 GD音乐台提供的免费API）

**如果你想使用自己的后端**：

1. 在 Cloudflare Pages 部署 Solara 项目（例如你的：`https://API.COM`）
2. 在加载项配置中修改 `api_url` 为你的域名
3. 重启加载项

**配置示例**：
```yaml
# 使用官方 GD音乐台 API（默认）
api_url: https://music.gdstudio.xyz

# 或使用你自己的 Cloudflare Pages
api_url: https://API.COM
```

**部署自己的 Cloudflare Pages 后端**：
- Fork 项目：https://github.com/akudamatata/Solara
- 在 Cloudflare Pages 中连接你的 GitHub 仓库
- 部署完成后使用你的域名

**注意**：确保 API URL 不要以斜杠结尾（正确：`https://domain.com`，错误：`https://domain.com/`）

### 跨域问题

由于浏览器的跨域限制，某些音乐源可能需要通过代理才能访问。

## 🐛 故障排除

### 查看日志

在加载项界面点击 "日志" 选项卡查看详细日志。

### 常见问题

1. **无法访问 Web UI**
   - 检查加载项是否正常启动
   - 确认端口 3100 没有被其他服务占用
   - 查看日志寻找错误信息

2. **搜索没有结果**
   - 检查浏览器控制台日志
   - 尝试切换不同的数据源
   - 确认 API 服务是否可用

3. **音频无法播放**
   - 可能是跨域问题
   - 检查后端代理是否正常工作
   - 尝试切换其他音源

4. **配置修改不生效**
   - 修改配置后需要重启加载项
   - 清除浏览器缓存后重新加载

## 📝 更新日志

### v1.0.0
- 初始版本
- 支持 amd64, aarch64, armv7 架构
- 集成 Ingress 支持
- 数据持久化支持

## 🔗 相关链接

- [Solara 源项目](https://github.com/akudamatata/Solara)
- [问题反馈](https://github.com/wuwweizn/wwzn-china/issues)
- [GD音乐台 API](https://music.gdstudio.xyz)

## 📄 许可证

本项目遵循源项目的 CC BY-NC-SA 协议，禁止任何商业化行为。