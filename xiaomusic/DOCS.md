# XiaoMusic HA 插件

使用小爱音箱播放本地/NAS 音乐，支持 yt-dlp 在线下载。

## 安装

将本插件目录放入你的 HA 自定义插件仓库，然后在加载项商店中安装。

## 配置说明

| 参数 | 说明 | 示例 |
|------|------|------|
| XIAOMUSIC_HOSTNAME | 本机 IP 地址（小爱音箱需要能访问到） | `192.168.1.100` |
| XIAOMUSIC_PORT | 服务监听端口 | `8090` |
| XIAOMUSIC_PUBLIC_PORT | 对外暴露端口（一般与 PORT 相同） | `8090` |
| XIAOMUSIC_ACCOUNT | 小米账号 | `your@email.com` |
| XIAOMUSIC_PASSWORD | 小米密码 | `yourpassword` |
| XIAOMUSIC_MI_DID | 设备 ID（可选，多设备时填写） | `123456789` |
| XIAOMUSIC_MUSIC_PATH | 音乐存放目录 | `/share/xiaomusic/music` |
| XIAOMUSIC_CONF_PATH | 配置文件目录 | `/share/xiaomusic/conf` |
| XIAOMUSIC_VERBOSE | 是否开启详细日志 | `false` |

## 目录说明

- 音乐目录和配置目录默认在 `/share/xiaomusic/` 下，HA 重启后数据不丢失。
- 可通过 Samba 或 FileBrowser 插件向音乐目录上传歌曲。

## 语音口令

对小爱同学说：
- 「播放歌曲 xxx」—— 搜索并播放
- 「下一首」
- 「上一首」
- 「单曲循环」/ 「全部循环」/ 「随机播放」
- 「关机」—— 停止播放
- 「刷新列表」—— 重新扫描音乐目录

## 数据来源

基于 [hanxi/xiaomusic](https://github.com/hanxi/xiaomusic) 官方镜像构建。
