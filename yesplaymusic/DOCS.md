
```markdown
# Home Assistant Add-on: YesPlayMusic

高颜值的第三方网易云播放器，支持本地音乐播放、离线歌单、桌面歌词。

## 安装

1. 在 Home Assistant 的监督面板中，导航到加载项商店。
2. 添加此仓库的 URL：`https://github.com/wuwweizn/wwzn-china`
3. 在加载项列表中找到 "YesPlayMusic" 并点击。
4. 点击 "安装" 按钮。

## 如何使用

1. 启动加载项。
2. 查看加载项的日志以确保一切正常启动。
3. 点击 "打开 Web UI" 或导航到 `http://homeassistant.local:3001`。
4. 使用网易云音乐账号登录。

## 配置

加载项配置页面允许您设置以下选项：

### 选项：`netease_api_url`

如果您有自己部署的网易云音乐 API 服务器，可以在此处设置其 URL。

## 网络端口

加载项使用以下端口：

- `80/tcp`：Web 界面端口，映射到主机的 3001 端口

## 故障排除

如果遇到问题：

1. 检查加载项日志中的错误信息。
2. 确保网络连接正常。
3. 如果使用自定义 API，请确保 API 服务器可访问。

## 支持

如需帮助，请访问：

- [YesPlayMusic 原项目](https://github.com/stark81/my_yesplaymusic)
- [Home Assistant 社区](https://community.home-assistant.io)