# Alist

Alist 是一个支持多种存储后端（如阿里云盘、OneDrive、本地硬盘等）的文件列表程序，支持 Web UI 管理与在线预览，适合个人 NAS、家庭媒体中心部署。

## 🧩 功能亮点

- 支持多种存储（阿里云盘、Google Drive、WebDAV、本地等）
- 支持在线视频预览
- 支持 Web UI 可视化配置
- 可独立运行，也可嵌入 Home Assistant

## 🔧 使用说明

- 默认端口：5244
- Web UI 地址：http://homeassistant.local:5244/

## 🗂️ 数据目录

- 所有配置、数据位于 `/data`，升级不会丢失数据。

## 🛡️ 权限说明

- 使用了 `SYS_ADMIN` 权限以支持 FUSE 或硬盘挂载等特性。
