# Home Assistant Add-on: YesPlayMusic

高颜值的第三方网易云播放器，支持本地音乐播放、离线歌单、桌面歌词。

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armhf Architecture][armhf-shield]
![Supports armv7 Architecture][armv7-shield]
![Supports i386 Architecture][i386-shield]

## About

YesPlayMusic 是一个高颜值的第三方网易云音乐播放器，支持以下特性：

- 🔴 网易云账号登录（扫码/手机/邮箱登录）
- 📺 支持 MV 播放
- 📃 支持歌词显示
- 📻 支持私人 FM / 每日推荐歌曲
- 🌚 Light/Dark Mode 自动切换
- ☁️ 支持音乐云盘
- 🔐 支持 UnblockNeteaseMusic

## Installation

1. 在 Home Assistant 中添加此仓库：`https://github.com/wuwweizn/wwzn-china`
2. 在加载项商店中找到 "YesPlayMusic"
3. 点击安装
4. 配置选项（可选）
5. 启动加载项

## Configuration

### Option: `netease_api_url`

网易云音乐 API 地址，如果不填写将使用默认配置。
```yaml
netease_api_url: "https://your-netease-api.example.com"