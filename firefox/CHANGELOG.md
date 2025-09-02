好的，我把这个 **更新日志（Changelog）** 翻译成中文：

---

## 1.6.0

* 基础镜像更新：`jlesage/docker-firefox` → 25.07.2（Firefox 114.0.4-r1）

  * 添加了网页界面的自动重连支持。
  * 添加了网页文件管理器（[Web File Manager](https://github.com/jlesage/docker-baseimage-gui?tab=readme-ov-file#web-file-manager)）。
  * 当启用网页认证时，访问网页界面不再要求 VNC 密码。
  * 其他更新和 bug 修复。

## 1.5.0

* 基础镜像更新：`jlesage/docker-firefox` → 25.03.1（Firefox 136.0-r0）

## 1.4.0

* 基础镜像更新：`jlesage/docker-firefox` → 24.12.1（Firefox 133.0-r0）
* 来自 jlesage 基础镜像的更改：

  * 修复基于 URL 路径的反向代理导致的网页音频问题。
  * 修复 VNC 的 TLS 安全连接方法，解决网页访问受阻的问题。
  * 修复 CJK（中日韩）字体安装问题。
  * 使用最新发行版镜像重建以获取安全修复。

## 1.3.2

* 基础镜像更新：`jlesage/docker-firefox` → 24.09.1（Firefox 130.0.1-r0）
* 增加通过网页浏览器启用音频支持的选项（当通过专用网页端口暴露插件时有效，不支持 Ingress）。
* HA 插件音频支持已启用（主机端，未测试）。
* 增加远程调试端口。
* 增加启用网页认证支持的选项。
* 增加设置 Firefox 自定义参数的选项。

## 1.2.0

* 基础镜像更新：`jlesage/docker-firefox` → 24.04.1（Firefox 124.0.1-r0）

## 1.1.0

* 基础镜像更新：`jlesage/docker-firefox` → 23.11.3
* 允许在 Home Assistant 主机上暴露 VNC 和网页端口，可用于 Kiosk 模式和默认 URL 场景。
* 菜单条目对所有用户可见（`panel_admin: false`）。
* 启用“legacy”模式，将选项作为环境变量使用。以下为部分可用选项示例：

  * 设置 VNC 密码。
  * 设置默认 URL。
  * 以 Kiosk 模式启动 Firefox。
  * 启用暗色模式（Dark Mode）。
  * 添加字体「文泉驿正黑」，支持中/日/韩字符。
  * 设置应用程序分辨率。

## 1.0.7

* 基础镜像更新：`jlesage/docker-firefox` → 23.05.2
* 从此版本开始，插件使用与基础镜像相同的仓库。
* 新增 “Firefox (Edge)” 插件，Edge 版本使用 Alpine Edge 仓库，并尝试在每次容器启动时更新 Firefox。

## 1.0.6

* 重建以升级 Firefox 至 113.0.2

## 1.0.5

* 基础镜像更新：`jlesage/docker-firefox` → 23.05.1

## 1.0.4

* 更新软件包名称格式

## 1.0.0

* 初始发布

---

如果你需要，我可以帮你做一个 **精简版中文更新日志表格**，只显示版本号、Firefox 版本和主要功能，更方便快速查看变化。

你想让我做吗？
