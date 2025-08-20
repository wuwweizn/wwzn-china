# Home Assistant Community Add-on: YesPlayMusic

![Logo][logo]

高颜值的第三方网易云音乐播放器 - 支持 Home Assistant 的 YesPlayMusic 加载项

## 关于

YesPlayMusic 是一个高颜值的第三方网易云音乐播放器，支持 Windows / macOS / Linux，现在也可以作为 Home Assistant 加载项运行。

特点：
- ✨ 使用 Vue.js 全家桶开发
- 🔴 网易云账号登录（扫码/手机/邮箱登录）
- 📺 支持 MV 播放
- 📃 支持歌词显示
- 📻 支持私人 FM / 每日推荐歌曲
- 🚫🤝 无任何社交功能
- 🌎️ 海外用户可直接播放（需要登录网易云账号）
- 🔐 支持 UnblockNeteaseMusic，自动使用 QQ/酷狗/酷我/Bilibili 等音源替换变灰歌曲链接（网页版不支持）
- ⏭️ 支持 MediaSession API，可以使用系统快捷键操作上一首下一首
- ✔️ 每日自动签到（手机端和电脑端同时签到）
- 🌚 Light/Dark 主题自动切换
- 👆 支持 Touch Bar
- 🖥️ 支持 PWA，可在 Chrome/Edge 里点击地址栏右边的 ➕ 安装到电脑
- 🎧 支持 Last.fm Scrobble
- 📱 移动端基础适配
- 🌐 支持 i18n，现已支持英语、中文简体、中文繁体、土耳其语

## 安装

1. 在 Home Assistant 中导航到 Supervisor
2. 点击 Add-on Store
3. 添加仓库：`https://github.com/wuwweizn/wwzn-china`
4. 找到 "YesPlayMusic" 加载项并点击安装

## 配置

### 选项

#### 基础设置

- **netease_api_url** (string, 可选): 网易云音乐 API 地址
  - 默认值: `http://47.121.211.116:3001`
  - 说明: 如果您有自己的 API 服务，可以修改此地址

- **port** (int, 可选): Web 界面端口
  - 默认值: `8080`
  - 范围: 1024-65535

#### 音质设置

- **music_quality** (list, 可选): 音乐播放音质
  - 选项: `standard`, `higher`, `exhigh`, `lossless`
  - 默认值: `standard`

#### 第三方集成

- **enable_lastfm** (bool, 可选): 启用 Last.fm Scrobble
  - 默认值: `false`

- **enable_discord_rpc** (bool, 可选): 启用 Discord Rich Presence
  - 默认值: `false`

#### 应用行为

- **close_app_option** (list, 可选): 关闭应用时的行为
  - 选项: `ask`, `close`, `minimize`
  - 默认值: `minimize`

- **auto_check_music** (bool, 可选): 自动检查音乐文件
  - 默认值: `true`

#### UnblockNeteaseMusic 设置

- **enable_unblock_netease_music** (bool, 可选): 启用 UnblockNeteaseMusic
  - 默认值: `false`
  - 说明: 自动使用其他音源替换变灰歌曲

- **unblock_netease_music_server** (string, 可选): UnblockNeteaseMusic 服务器地址
  - 默认值: `""`

#### 界面设置

- **language** (list, 可选): 界面语言
  - 选项: `zh-CN`, `zh-TW`, `en`, `tr`
  - 默认值: `zh-CN`

- **appearance** (list, 可选): 外观主题
  - 选项: `auto`, `light`, `dark`
  - 默认值: `auto`

- **accent_color** (string, 可选): 主题色
  - 默认值: `#335eea`
  - 说明: 支持任何有效的 CSS 颜色值

#### 歌词设置

- **lyrics_background** (bool, 可选): 歌词页面显示模糊背景
  - 默认值: `true`

- **show_lyrics_translation** (bool, 可选): 显示歌词翻译
  - 默认值: `true`

#### 缓存设置

- **music_cache_size** (list, 可选): 音乐缓存大小
  - 选项: `1GB`, `2GB`, `4GB`, `8GB`, `unlimited`
  - 默认值: `2GB`

### 示例配置

```yaml
netease_api_url: "http://47.121.211.116:3001"
port: 8080
music_quality: "higher"
enable_lastfm: false
enable_discord_rpc: false
close_app_option: "minimize"
auto_check_music: true
enable_unblock_netease_music: false
unblock_netease_music_server: ""
language: "zh-CN"
appearance: "auto"
accent_color: "#335eea"
lyrics_background: true
show_lyrics_translation: true
music_cache_size: "2GB"
```

## 使用

1. 启动加载项后，通过 Web UI 或点击 "OPEN WEB UI" 按钮访问
2. 使用网易云音乐账号登录（支持扫码登录、手机号登录、邮箱登录）
3. 开始享受音乐吧！

## 网易云音乐 API

此加载项需要网易云音乐 API 服务才能正常工作。默认配置的 API 服务地址为 `http://47.121.211.116:3001`。

如果您希望使用自己的 API 服务，可以：

1. 部署自己的网易云音乐 API 服务（推荐使用 [NeteaseCloudMusicApi](https://github.com/Binaryify/NeteaseCloudMusicApi)）
2. 在加载项配置中修改 `netease_api_url` 为您的 API 服务地址

## 支持

如果您遇到任何问题或有功能请求，请通过以下方式寻求帮助：

- [GitHub Issues](https://github.com/wuwweizn/wwzn-china/issues)
- [原项目地址](https://github.com/stark81/my_yesplaymusic)

## 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 致谢

- 感谢 [stark81](https://github.com/stark81) 维护的 [my_yesplaymusic](https://github.com/stark81/my_yesplaymusic) 项目
- 感谢原作者 [qier222](https://github.com/qier222) 的 [YesPlayMusic](https://github.com/qier222/YesPlayMusic) 项目
- 感谢 [Binaryify](https://github.com/Binaryify) 的 [NeteaseCloudMusicApi](https://github.com/Binaryify/NeteaseCloudMusicApi) 项目

[logo]: https://raw.githubusercontent.com/qier222/YesPlayMusic/main/src/assets/icons/icon.png