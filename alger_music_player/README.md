# Alger Music Player - Home Assistant Add-on

一个第三方音乐播放器Home Assistant加载项，基于[AlgerMusicPlayer](https://github.com/algerkong/AlgerMusicPlayer)项目构建。

## 功能特性

- 🎵 **音乐推荐** - 支持网易云音乐推荐功能
- 🔐 **账号登录** - 网易云账号登录与同步
- 📝 **完整功能**
  - 播放历史记录
  - 歌曲收藏管理
  - 歌单、MV、排行榜、每日推荐
  - 自定义快捷键配置
- 🎨 **界面与交互**
  - 沉浸式歌词显示
  - 明暗主题切换
  - 迷你模式
  - 多语言支持
- 🎼 **音乐功能**
  - 支持歌单、MV、专辑等完整音乐服务
  - 高品质音乐播放
  - 音乐文件下载
  - 搜索功能（音乐、MV、专辑、歌单、bilibili）
  - 音乐单独选择音源解析
- 🚀 **技术特性**
  - 本地化服务，无需依赖在线API
  - 全平台适配（Desktop & Web & Mobile Web）

## 安装说明

1. 在Home Assistant的监督者页面中，添加此仓库：
   ```
   https://github.com/wuwweizn/wwzn-china
   ```

2. 刷新加载项商店，找到"Alger Music Player"

3. 点击安装并配置

## 配置选项

### `music_api_url` (可选)
- 默认值: `http://localhost:3001`
- 说明: 外部音乐API服务地址，用于获取音乐播放链接
- 示例: `https://your-music-api.com/api/getMusicUrl?level=high`

### `log_level` (可选)
- 默认值: `info`
- 可选值: `trace`, `debug`, `info`, `notice`, `warning`, `error`, `fatal`
- 说明: 日志输出级别

## 配置示例

```yaml
music_api_url: "https://your-music-api.com/getMusicUrl?level=high&format=json"
log_level: "info"
```

## 使用方法

1. 启动加载项后，通过Web UI或Home Assistant面板访问
2. 首次使用建议登录网易云账号以获得完整功能
3. 可以通过配置外部音乐API来获取高品质音乐

## 端口说明

- **8080**: Web界面端口
- 内部API通过nginx代理：
  - `/api/` - 内部netease-cloud-music-api
  - `/api_music/` - 外部音乐API代理

## API接口要求

如果配置了外部音乐API（`music_api_url`），该API需要：

1. 支持通过 `id` 参数获取音乐播放链接
2. 返回JSON格式数据，如：`{"data":{"url":"music_url"}}`
3. 建议支持CORS

系统会自动从请求中提取`id`参数并追加到配置的URL末尾。

## 注意事项

- 本软件仅用于学习交流，禁止用于商业用途
- 建议支持官方正版音乐服务
- 如遇到网络问题，可尝试配置外部音乐API

## 支持

如有问题，请访问：
- 原项目: https://github.com/algerkong/AlgerMusicPlayer
- 加载项仓库: https://github.com/wuwweizn/wwzn-china

## 许可证

基于原项目许可证，仅用于学习交流目的。