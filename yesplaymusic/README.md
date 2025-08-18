# YesPlayMusic Home Assistant 加载项

高颜值的第三方网易云音乐播放器，支持在Home Assistant中运行。

## 功能特点

- 🎵 高颜值的网易云音乐播放器界面
- 🔧 可配置的网易云API服务地址
- 🌐 支持HTTP和HTTPS访问
- 📱 响应式设计，支持移动端
- 🔗 完整的Home Assistant集成

## 配置选项

### `netease_api_url` (字符串，必填)
网易云音乐API服务器地址。默认值：`http://47.121.211.116:3001`

### `port` (整数，可选)
YesPlayMusic服务端口。默认值：`80`

### `ssl` (布尔值，可选)
是否启用HTTPS。默认值：`false`

### `certfile` (字符串，可选)
SSL证书文件名（在/ssl目录中）。默认值：`fullchain.pem`

### `keyfile` (字符串，可选)
SSL私钥文件名（在/ssl目录中）。默认值：`privkey.pem`

## 安装步骤

1. **添加仓库**：在Home Assistant的Supervisor -> Add-on Store中添加仓库：
   ```
   https://github.com/wuwweizn/wwzn-china
   ```

2. **安装加载项**：在加载项商店中找到"YesPlayMusic"并点击安装。

3. **配置加载项**：在配置选项卡中设置您的网易云API地址。

4. **启动加载项**：点击"启动"按钮。

5. **访问界面**：点击"打开Web UI"或通过侧边栏访问。

## 网易云API部署

YesPlayMusic需要配合网易云音乐API服务使用。您可以：

1. 使用提供的默认API地址：`http://47.121.211.116:3001`
2. 自行部署网易云音乐API服务器

### 自行部署API服务

```bash
# 克隆API项目
git clone https://github.com/Binaryify/NeteaseCloudMusicApi.git
cd NeteaseCloudMusicApi

# 安装依赖
npm install

# 启动服务
node app.js
```

## 使用说明

1. 启动加载项后，您可以通过Home Assistant的侧边栏或Web UI访问YesPlayMusic
2. 首次使用需要登录您的网易云音乐账号
3. 登录后即可享受完整的音乐播放体验

## 故障排除

### 无法连接到API服务器
- 检查`netease_api_url`配置是否正确
- 确保API服务器正在运行且可访问
- 检查防火墙设置

### SSL证书问题
- 确保证书文件存在于`/ssl`目录中
- 检查证书文件名是否与配置匹配
- 验证证书有效性

### 播放问题
- 检查网络连接
- 确认账号登录状态
- 验证API服务器功能正常

## 支持

如有问题，请访问：
- [YesPlayMusic 原项目](https://github.com/qier222/YesPlayMusic)
- [加载项仓库](https://github.com/wuwweizn/wwzn-china)

## 版权说明

本加载项基于开源项目YesPlayMusic构建，仅供个人学习和使用。请遵守相关音乐版权法规。