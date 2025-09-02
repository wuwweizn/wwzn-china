# Supervisor Updater - Home Assistant 加载项

这是一个专门用于更新 Home Assistant Supervisor 的加载项，特别针对国内网络环境优化，使用阿里云镜像源来避免 Docker 镜像拉取问题。

## 🚀 功能特点

- **一键更新**: 点击按钮即可开始更新 Supervisor
- **实时进度**: 显示更新进度条和状态
- **详细日志**: 实时显示更新过程的详细日志
- **阿里云镜像**: 使用国内镜像源，解决网络问题
- **美观界面**: 现代化的 Web 界面设计
- **动态版本**: 自动从云端获取最新版本信息

## 📋 系统要求

- Home Assistant OS 或 Supervised 安装
- 支持 Docker 的架构 (armhf, armv7, aarch64, amd64, i386)
- 网络访问阿里云镜像源

## 🛠️ 安装方法

1. 将整个文件夹复制到你的 Home Assistant 的 `addons` 目录
2. 在 Home Assistant 中安装这个加载项
3. 启动加载项
4. 通过 Web UI 进行 Supervisor 更新

## 🎯 使用方法

### 1. 启动加载项
在 Home Assistant 的加载项页面启动 "Supervisor Updater"

### 2. 访问界面
- 通过加载项页面点击 "打开 Web UI"
- 或者直接访问: `http://your-ha-ip:8124`

### 3. 开始更新
1. 点击 "开始更新" 按钮
2. 观察进度条和状态更新
3. 查看实时日志输出
4. 等待更新完成

## 🔧 自定义配置

### 修改云端版本源
如果需要修改版本信息源，请联系开发者更新云端配置。

### 修改端口
在 `config.yaml` 中修改端口号：
```yaml
ports:
  8125/tcp: 8125  # 改为你想要的端口
```

## 🚨 注意事项

- 此加载项具有管理员权限，请谨慎使用
- 更新过程会重启 Supervisor 服务
- 建议在维护时间窗口内进行更新
- 更新前建议备份 Home Assistant 配置

## 🆘 故障排除

如果遇到问题：
1. 查看加载项日志
2. 检查系统权限设置
3. 确认网络连接状态
4. 联系技术支持

## 📄 许可证

MIT License

---

**注意**: 此加载项用于更新 Home Assistant Supervisor，请在理解其功能和安全影响后使用。
