# XiaoMusic

![版本](https://img.shields.io/badge/版本-0.3.101-blue)
![架构](https://img.shields.io/badge/架构-amd64%20%7C%20aarch64%20%7C%20armv7-green)
![许可](https://img.shields.io/badge/许可-MIT-orange)

> 使用小爱音箱播放本地及在线音乐，音乐下载基于 yt-dlp。

---

## 简介

**XiaoMusic** 是一个让小爱音箱突破官方限制、自由播放音乐的开源项目。  
本加载项将 XiaoMusic 打包为 Home Assistant 加载项，让你无需单独部署 Docker，直接在 HA 中管理使用。

- 原项目地址：[https://github.com/hanxi/xiaomusic](https://github.com/hanxi/xiaomusic)
- 原项目文档：[https://xdocs.hanxi.cc](https://xdocs.hanxi.cc)

---

## 功能特性

- 🎵 播放 HA 媒体库（`/media`）中的本地音乐
- 🌐 语音口令触发 yt-dlp 在线下载并播放
- 🔁 支持单曲循环、全部循环、随机播放
- 📋 支持自定义歌单、网络歌单（电台）
- ⭐ 支持收藏歌曲
- 🔍 支持关键词搜索播放
- 🛠️ 支持自定义语音口令和插件

---

## 支持的设备

| 型号 | 名称 |
|------|------|
| L06A | 小爱音箱 |
| L07A | Redmi 小爱音箱 Play |
| S12/S12A | 小米 AI 音箱 |
| LX05 | 小爱音箱 Play（2019款）|
| LX06 | 小爱音箱 Pro |
| LX01 | 小爱音箱 mini |
| L05B/L05C | 小爱音箱 Play / 增强版 |
| L15A/L16A/L17A | 小米 AI 音箱二代 / Xiaomi Sound / Pro |
| LX04/X10A/X08A | 触屏版 |
| 更多… | 基本全系列支持 |

---

## 支持的音乐格式

`mp3` · `flac` · `wav` · `ape` · `ogg` · `m4a`

---

## 安装方法

1. 在 Home Assistant 中进入 **设置 → 加载项 → 加载项商店**
2. 点击右上角菜单 → **自定义仓库**
3. 添加仓库地址：`https://github.com/wuwweizn/wwzn-china`
4. 刷新后找到 **XiaoMusic**，点击安装
5. 安装完成后点击 **启动**，再点击 **打开 Web 界面** 进行初始配置

详细配置说明见 [DOCS.md](DOCS.md)

---

## 免责声明

本加载项仅供学习和研究目的，不得用于商业活动。使用本项目所产生的一切风险由使用者自行承担。
