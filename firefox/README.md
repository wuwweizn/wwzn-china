# Home Assistant 插件：Firefox

*在 Home Assistant 内部运行 Firefox 浏览器，从家中访问本地或外部网站。*

![支持 aarch64 架构][aarch64-shield]
![支持 amd64 架构][amd64-shield]
![支持 armv7 架构][armv7-shield]
![支持 i386 架构][i386-shield]

---

## 关于

Mozilla Firefox 是由 Mozilla 基金会及其子公司 Mozilla Corporation 开发的免费开源网页浏览器。

本插件基于 [Jocelyn Le Sage 的 Docker 镜像](https://github.com/jlesage/docker-firefox) 构建。

特别感谢他创建和维护了这些优秀的容器，他是真正的英雄，值得我们 [支持](https://github.com/sponsors/jlesage)。

---

## 与原始容器的区别

为了兼容 Home Assistant 的持久化存储，我需要重新映射文件夹，因此启动脚本以 `root` 身份运行。
未来我会尝试避免这种做法。

---

## 使用方法

只需安装并启动容器，然后点击 **“Open Web UI”** 打开浏览器界面。
你可以使用 **“Show in sidebar”** 将其固定在侧边栏以便快速访问。
你在 Firefox 中的所有操作都会被持久保存，即使你停止插件或重启 Home Assistant 主机系统，数据依然保留。

---

## 下载文件

Firefox 下载的文件会自动保存到 `/share/firefox` 文件夹。

---

## 上传文件

如果你需要通过 Firefox 插件上传文件，可以使用 [File editor 插件](https://github.com/home-assistant/addons/blob/master/configurator/) 将文件上传到 `/share/firefox` 文件夹。
上传的文件会出现在插件的 `downloads` 文件夹中，你选择文件上传时可以浏览到这个位置。

---

## 导入书签

你可以将 `bookmarks.html` 文件放入 `/share/firefox` 文件夹中，然后在 Firefox 中导入该书签文件。

---

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg


