# YesPlayMusic - Home Assistant Add-on

![YesPlayMusic Logo](https://repository-images.githubusercontent.com/330851515/ddc39f00-5fb5-11eb-8c4b-0bfa28ca5419)

高颜值的第三方网易云播放器，现已制作为 Home Assistant 加载项！

## 关于

YesPlayMusic 是一款功能强大且美观的第三方网易云音乐播放器，具有以下特性：

- ✅ 使用 Vue.js 全家桶开发
- 🔴 网易云账号登录（扫码/手机/邮箱登录）
- 📺 支持 MV 播放
- 📃 支持歌词显示
- 📻 支持私人 FM / 每日推荐歌曲
- 🚫🤝 无任何社交功能
- 🌎️ 海外用户可直接播放（需要登录网易云账号）
- 🔐 支持 UnblockNeteaseMusic
- ✔️ 每日自动签到
- 🌚 Light/Dark Mode 自动切换
- 🖥️ 支持 PWA
- ☁️ 支持音乐云盘

## 安装

### 方法1：通过 Home Assistant 商店（推荐）

1. 在 Home Assistant 中，转到 **Supervisor** → **Add-on Store**
2. 点击右上角的三个点，选择 **Repositories**
3. 添加此仓库：`https://github.com/wuwweizn/wwzn-china`
4. 搜索 "YesPlayMusic" 并点击安装
5. 安装完成后，点击 "START" 启动加载项

### 方法2：手动安装

1. 复制 `yesplaymusic` 文件夹到你的 Home Assistant 加载项目录
2. 重启 Home Assistant
3. 在加载项页面找到 YesPlayMusic 并安装

## 配置选项

### 基本配置

| 选项 | 类型 | 默认值 | 描述 |
|------|------|--------|------|
| `netease_api_url` | string | `https://music-api.hankqin.com` | 网易云API服务器地址 |
| `ssl` | boolean | `false` | 启用SSL（需要配置证书） |
| `certfile` | string | `fullchain.pem` | SSL证书文件名 |
| `keyfile` | string | `privkey.pem` | SSL私钥文件名 |
| `custom_title` | string | `YesPlayMusic` | 自定义页面标题 |
| `log_level` | string | `info` | 日志级别 |

### 网易云API配置

本加载项默认使用公共API服务器，你也可以：

1. **使用默认API**（推荐）：无需配置，开箱即用
2. **自建API服务器**：
   ```bash
   # 克隆API项目
   git clone https://github.com/Binaryify/NeteaseCloudMusicApi.git
   cd NeteaseCloudMusicApi
   npm install
   node app.js
   ```
   然后将 `netease_api_url` 设置为你的API地址

3. **使用其他公共API**：
   - `https://netease-cloud-music-api-psi-five.vercel.app`
   - `https://music-api.hankqin.com`

## 使用方法

1. 启动加载项后，访问 Web UI
2. 首次使用建议登录网易云账号以获得完整体验
3. 支持多种登录方式：
   - 扫码登录（推荐）
   - 手机号登录
   - 邮箱登录

## 功能特色

### 🎵 音乐播放
- 支持高品质音乐播放
- 智能音源切换
- 私人FM和每日推荐
- 音乐云盘支持

### 🎬 视频体验
- MV播放支持
- 高清画质选择

### 📱 现代界面
- 响应式设计
- 深色/浅色主题
- PWA支持，可安装到桌面

### 🔐 隐私安全
- 无社交功能干扰
- 本地数据存储
- 支持海外访问

## 故障排除

### 无法播放音乐
1. 检查网络连接
2. 确认API服务器状态
3. 尝试登录网易云账号
4. 检查Home Assistant日志

### API连接问题
1. 验证 `netease_api_url` 配置是否正确
2. 检查防火墙设置
3. 尝试使用其他API服务器

### 登录问题
1. 确保API服务器支持登录功能
2. 检查网络连接
3. 尝试不同的登录方式

## 更新日志

### v1.0.3
- 初始版本发布
- 支持多架构部署 (amd64, arm64, armv7)
- 集成 Nginx 反向代理
- 支持 SSL 配置
- 优化性能和稳定性

## 技术支持

- **项目地址**: https://github.com/qier222/YesPlayMusic
- **问题反馈**: https://github.com/wuwweizn/wwzn-china/issues
- **API项目**: https://github.com/Binaryify/NeteaseCloudMusicApi

## 许可证

本项目基于 MIT 许可证开源，仅供个人学习研究使用。

## 致谢

- 感谢 [qier222](https://github.com/qier222) 开发的 YesPlayMusic
- 感谢 [Binaryify](https://github.com/Binaryify) 提供的网易云API
- 感谢所有贡献者的付出