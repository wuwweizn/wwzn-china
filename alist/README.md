# Alist Home Assistant 加载项

#快速配置使用
1.安装
2.启动
3.访问：http://HA-IP:5244
4.alist登录：用户名：admin  密码：ovL6BOgY （查看日志中随机生成）
例如：
INFO[2025-09-01 20:55:06] username: admin                              
INFO[2025-09-01 20:55:06] password: ovL6BOgY 
 
注意：如有端口冲突，可在配置页自行配置端口

## 简介

Alist 是一个支持多存储的文件列表/WebDAV程序，使用 Gin 和 SolidJS 构建。它可以将多个云存储平台聚合在一个 Web 界面中进行统一管理。

## 🌟 主要功能

### 📁 多存储支持
支持 **60+** 种存储后端，包括：
- **云存储**: 阿里云盘、百度网盘、OneDrive、Google Drive、Dropbox等
- **对象存储**: AWS S3、MinIO、阿里云OSS、腾讯云COS等
- **网盘服务**: 蓝奏云、123云盘、夸克网盘、迅雷云盘等
- **本地存储**: 本地文件系统、FTP、SFTP、WebDAV等
- **其他服务**: Alist、PikPak、MediaTrack等

### 🔄 WebDAV 支持
- 完整的 WebDAV 协议支持
- 可作为 WebDAV 服务器使用
- 支持第三方客户端连接

### 🎥 媒体预览
- 视频在线播放
- 音频在线播放  
- 图片预览
- 办公文档预览
- PDF 预览
- 代码文件预览

### 📦 下载功能
- 直链下载
- 打包下载
- Aria2 离线下载
- 批量下载

### 🔐 安全功能
- 用户权限管理
- 访问密码保护
- JWT 认证
- CORS 跨域支持

## 安装说明

### 1. 添加仓库
在Home Assistant的加载项商店中，点击右上角菜单，选择"仓库"，添加以下URL：

```
https://github.com/wuwweizn/wwzn-china
```

### 2. 安装加载项
1. 在加载项商店中找到"Alist"
2. 点击安装
3. 等待安装完成

### 3. 配置加载项

#### 基础配置
- **web_port**: Web管理界面端口 (默认: 5244)
- **admin_username**: 管理员用户名 (默认: admin)
- **admin_password**: 管理员密码 (留空将使用随机生成的密码)
- **log_level**: 日志级别 (DEBUG/INFO/WARN/ERROR)

#### 扩展功能
- **enable_aria2**: 启用Aria2离线下载 (默认: false)
- **enable_ffmpeg**: 启用FFmpeg视频处理 (默认: false)
- **enable_webdav**: 启用WebDAV功能 (默认: true)

#### 配置示例
```json
{
  "web_port": 5244,
  "admin_username": "admin",
  "admin_password": "your_secure_password",
  "log_level": "INFO",
  "enable_aria2": true,
  "enable_ffmpeg": true,
  "enable_webdav": true
}
```

### 4. 启动加载项
1. 启用"开机自启"
2. 点击"启动"
3. 检查日志确认启动成功

## 访问界面

启动成功后，可以通过以下方式访问Alist：

- 直接访问: `http://YOUR_HA_IP:5244`
- 或点击加载项页面的"打开Web UI"按钮

### 首次登录

如果未设置管理员密码，请查看加载项日志获取随机生成的密码：

```bash
# 日志中会显示类似信息
INFO get admin user's info:
username: admin
password: randomly_generated_password
```

⚠️ **重要**: 首次登录后请立即修改密码！

## 存储配置

### 添加存储
1. 登录Alist管理界面
2. 点击"存储"菜单
3. 点击"添加"按钮
4. 选择存储类型并填写相关信息

### 本地存储配置
- **挂载路径**: `/local` (推荐)
- **根文件夹路径**: `/share` (访问HA共享目录)
- 或使用 `/media`, `/backup` 等HA目录

### WebDAV访问
如果启用WebDAV功能，可通过以下地址访问：
```
http://YOUR_HA_IP:5244/dav/
```

## 下载配置

### Aria2离线下载
如果启用了Aria2功能：
1. 下载文件会保存到 `/downloads` 目录
2. 该目录映射到HA的共享存储
3. 支持HTTP、FTP、BitTorrent下载

### 直链下载
- 支持断点续传
- 支持多线程下载
- 支持打包下载文件夹

## 存储路径说明

### 容器内路径映射
- `/opt/alist/data` → `/config/alist` (配置和数据)
- `/downloads` → HA共享存储 (下载目录)
- `/share` → HA共享目录
- `/media` → HA媒体目录
- `/backup` → HA备份目录

### 推荐目录结构
```
/config/alist/
├── data/           # Alist数据库和配置
├── log/            # 日志文件
└── temp/           # 临时文件
```

## 常见问题

### Q: 如何重置管理员密码？
A: 在加载项日志中执行：
```bash
# 查看当前密码
docker exec -it alist_container /opt/alist/alist admin --data /config/alist/data

# 设置新密码
docker exec -it alist_container /opt/alist/alist admin set NEW_PASSWORD --data /config/alist/data
```

### Q: 如何配置云存储？
A: 登录Web界面后，在"存储"页面添加相应的云存储服务。每种存储都有详细的配置说明。

### Q: WebDAV无法连接？
A: 检查以下设置：
- 确保 `enable_webdav` 为 true
- WebDAV地址: `http://YOUR_HA_IP:5244/dav/`
- 使用Alist的登录用户名和密码

### Q: 视频无法播放？
A: 
- 启用 `enable_ffmpeg` 选项
- 确保视频格式被支持
- 检查网络连接和文件权限

### Q: 下载速度慢？
A: 
- 启用 `enable_aria2` 进行多线程下载
- 检查存储后端的下载限制
- 考虑使用CDN或代理

### Q: 如何备份配置？
A: 配置文件位于 `/config/alist/` 目录，会随HA备份自动备份。

## 性能优化

### 内存使用
- 基础运行: ~50MB
- 启用Aria2: +30MB
- 启用FFmpeg: +20MB

### 存储建议
- 为频繁访问的文件使用本地存储
- 大文件建议使用对象存储
- 临时文件定期清理

### 网络优化
- 使用CDN加速静态资源
- 配置适当的缓存策略
- 启用gzip压缩

## 安全建议

### 访问控制
1. 设置强密码
2. 定期更换密码
3. 限制访问IP范围
4. 启用HTTPS（推荐）

### 数据安全
1. 定期备份配置
2. 谨慎设置文件权限
3. 避免暴露敏感目录
4. 监控访问日志

## 支持的存储类型

### 云盘服务
- 阿里云盘 - 国内主流云盘
- 百度网盘 - 需要SVIP
- OneDrive - 微软云存储
- Google Drive - 谷歌云存储
- Dropbox - 国外主流云盘
- iCloud Drive - 苹果云存储

### 对象存储
- AWS S3 - 亚马逊对象存储
- MinIO - 开源对象存储
- 阿里云OSS - 阿里云对象存储
- 腾讯云COS - 腾讯云对象存储
- 七牛云 - Kodo对象存储
- 又拍云 - USS对象存储

### 网盘服务
- 蓝奏云 - 免费网盘
- 123云盘 - 国内网盘
- 夸克网盘 - UC夸克
- 迅雷云盘 - 迅雷网盘
- 天翼云盘 - 电信云盘
- 移动云盘 - 中国移动

### 其他存储
- FTP/SFTP - 文件传输协议
- WebDAV - 网络分布式创作
- 本地存储 - 本地文件系统
- Alist - 其他Alist实例
- PikPak - 海外网盘服务

## 高级配置

### 自定义配置
可通过 `custom_config` 选项添加高级配置：

```json
{
  "custom_config": {
    "max_connections": 100,
    "temp_dir": "temp",
    "database": {
      "type": "sqlite3"
    },
    "cors": {
      "allow_origins": ["*"]
    }
  }
}
```

### 环境变量
支持的环境变量：
- `PUID`: 用户ID (默认: 0)
- `PGID`: 用户组ID (默认: 0) 
- `UMASK`: 文件权限掩码 (默认: 022)
- `TZ`: 时区 (默认: Asia/Shanghai)

## 更新日志

### v3.41.0
- 优化WebDAV性能
- 修复已知安全问题
- 新增多个存储后端支持
- 改进用户界面体验

### 升级说明
- 配置文件自动迁移
- 数据库结构自动更新
- 建议升级前备份配置

## 贡献与支持

### 相关链接
- 官方网站: https://alist.nn.ci
- 项目仓库: https://github.com/AlistGo/alist
- 文档地址: https://alist.nn.ci/guide/
- 问题反馈: https://github.com/wuwweizn/wwzn-china/issues

### 许可证
本加载项基于Alist项目，遵循AGPL-3.0开源协议。

### 致谢
感谢 [AlistGo](https://github.com/AlistGo) 团队开发的优秀文件管理系统。