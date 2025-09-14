# Alger Music Player Add-on

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armhf Architecture][armhf-shield]
![Supports armv7 Architecture][armv7-shield]
![Supports i386 Architecture][i386-shield]

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg

基于 React + Express 的网易云音乐播放器，支持高音质播放和自定义音乐 API。

## 关于

Alger Music Player 是一个现代化的音乐播放器，提供以下功能：

- 🎵 网易云音乐资源播放
- 🎨 Material Design 风格界面
- 📱 响应式设计，支持移动端
- 🔊 高音质音乐播放
- 🔧 支持自定义音乐 API
- 🚀 快速搜索和播放

## 安装

1. 点击 Home Assistant 中的 "Supervisor" 面板
2. 点击 "Add-on Store"
3. 点击右上角菜单，选择 "Repositories"
4. 添加此仓库：`https://github.com/wuwweizn/wwzn-china`
5. 找到 "Alger Music Player" 并点击安装

## 配置

### 选项

#### `music_api_url` (可选)

自定义音乐 API URL，默认使用内置的音乐服务。

**注意**: API URL 应该是完整地址，系统会自动追加 `&id=songId` 参数。

示例:
```yaml
music_api_url: "https://your-music-api.com/api/getMusicUrl?level=high"