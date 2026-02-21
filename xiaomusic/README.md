# XiaoMusic - Home Assistant 加载项

[![GitHub Release](https://img.shields.io/github/v/release/hanxi/xiaomusic?label=上游版本)](https://github.com/hanxi/xiaomusic/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

使用小爱音箱播放本地或网络音乐，支持 yt-dlp 下载，语音口令控制播放。

> 上游项目：[hanxi/xiaomusic](https://github.com/hanxi/xiaomusic)
> 本加载项镜像由 [wuwweizn/wwzn-china](https://github.com/wuwweizn/wwzn-china) 自建仓库构建托管。

---

## 📦 安装方法

### 第一步：添加仓库

在 Home Assistant 中依次点击：

**设置 → 加载项 → 加载项商店 → 右上角 ⋮ → 仓库**

在弹出框中添加以下地址：

```
https://github.com/wuwweizn/wwzn-china
```

刷新页面后即可在加载项商店中找到 **XiaoMusic**。

### 第二步：安装加载项

点击 XiaoMusic → 安装 → 等待镜像拉取完成。

### 第三步：配置加载项

在加载项的「配置」标签页中填写以下参数：

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `public_port` | 对外暴露的 Web 端口 | `58090` |

### 第四步：启动并访问

点击「启动」，启动成功后访问：

```
http://<HA_IP>:58090
```

或直接点击侧边栏「XiaoMusic」面板内嵌访问。

首次使用需在 Web 页面输入**小米账号和密码**，保存后才能获取设备列表。

---

## 🎵 支持的语音口令

| 口令 | 说明 |
|------|------|
| 播放歌曲 | 随机播放本地音乐 |
| 播放歌曲 + 歌名 | 例：播放歌曲周杰伦晴天 |
| 上一首 / 下一首 | 切换曲目 |
| 单曲循环 / 全部循环 / 随机播放 | 切换播放模式 |
| 停止播放 / 关机 | 停止播放 |
| 刷新列表 | 扫描 music 目录更新歌单 |
| 播放列表 + 列表名 | 例：播放列表收藏 |
| 加入收藏 / 取消收藏 | 收藏当前歌曲 |
| 搜索播放 + 关键词 | 搜索并播放，找不到会自动下载 |
| 本地搜索播放 + 关键词 | 仅搜索本地，不下载 |

---

## 🎵 支持的音乐格式

`mp3` · `flac` · `wav` · `ape` · `ogg` · `m4a`

> 注意：部分型号（如 L05B、L05C、LX06、L16A）不支持 flac，建议开启「转换为MP3」选项。

---

## 📁 目录说明

| HA 路径 | 容器路径 | 说明 |
|---------|---------|------|
| `/share/xiaomusic/music` | `/share/xiaomusic/music` | 音乐文件存放目录（通过 share 映射） |
| `/data/conf` | `/data/conf` | 配置文件持久化目录（升级不丢失） |

可通过 HA 的**文件管理器**或 **Samba** 加载项向 `/share/xiaomusic/music` 上传音乐，上传后对小爱说「刷新列表」即可生效。

---

## 🏗️ 镜像构建说明

支持架构：

| HA 架构标识 | Docker 平台 | GHCR 镜像 |
|------------|------------|----------|
| `amd64` | `linux/amd64` | `ghcr.io/wuwweizn/xiaomusic-amd64` |
| `aarch64` | `linux/arm64` | `ghcr.io/wuwweizn/xiaomusic-aarch64` |
| `armv7` | `linux/arm/v7` | `ghcr.io/wuwweizn/xiaomusic-armv7` |

---

## ⚠️ 安全提醒

- 若将 XiaoMusic 暴露到公网，请务必在 Web 页面**开启密码登录**并设置复杂密码。
- 切勿在公共 WiFi 环境下使用，以防小米账号密码泄露。
- 强烈不建议将绑定摄像头的小米账号用于本应用。

---

## 🐛 问题反馈

- 上游 Bug / 功能建议：[hanxi/xiaomusic Issues](https://github.com/hanxi/xiaomusic/issues)
- 加载项打包问题：[wuwweizn/wwzn-china Issues](https://github.com/wuwweizn/wwzn-china/issues)

---

## 📄 许可证

本加载项遵循 [MIT License](https://github.com/hanxi/xiaomusic/blob/main/LICENSE)，上游项目版权归 [hanxi](https://github.com/hanxi) 所有。
