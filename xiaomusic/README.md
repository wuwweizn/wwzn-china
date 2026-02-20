# XiaoMusic Home Assistant Add-on

使用小爱音箱播放音乐，音乐使用 yt-dlp 下载。

## 安装

1. 在 Home Assistant 加载项商店中，点击右上角菜单 → **添加仓库**
2. 输入仓库地址：`https://github.com/wuwweizn/wwzn-china`
3. 安装 **XiaoMusic** 加载项
4. 启动后访问 Web UI：`http://HA-IP:58090`

## 配置

启动后在 Web UI 中填写**小米账号和密码**，然后保存即可获取设备列表。

- **音乐目录**：映射到 `/share/xiaomusic/music`
- **配置目录**：映射到 HA 的 `/config`

## 上游项目

- 原项目：[hanxi/xiaomusic](https://github.com/hanxi/xiaomusic)
- 文档：[xdocs.hanxi.cc](https://xdocs.hanxi.cc)
```

---

## ?? 部署步骤总结

按以下顺序操作你的 `wuwweizn/wwzn-china` 仓库：

**① 创建上述 5 个文件并推送到 `main` 分支**

**② 确保 GHCR 包可公开访问**
推送成功后，到 GitHub → Settings → Packages，把 `xiaomusic-amd64`、`xiaomusic-aarch64`、`xiaomusic-armv7` 这三个包的可见性改为 **Public**（否则 HA Supervisor 拉取时会报 403）。

**③ 在 Home Assistant 添加仓库**
进入 HA → 加载项商店 → 右上角三点菜单 → **添加仓库** → 输入：
```
https://github.com/wuwweizn/wwzn-china