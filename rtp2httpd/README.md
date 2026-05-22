# rtp2httpd Home Assistant 加载项

IPTV 组播转单播转发服务器，支持将组播 RTP/UDP、RTSP 流转换为 HTTP 单播流，内置 Web 状态面板、播放器与快速换台（FCC）功能。

- 官方项目：[github.com/stackia/rtp2httpd](https://github.com/stackia/rtp2httpd)
- 官方文档：[rtp2httpd.com](https://rtp2httpd.com)

---

## 前提条件

> **重要**：rtp2httpd 需要 HA 主机能收到运营商 IPTV 的组播数据包。  
> 通常需要在路由器（如 OpenWrt）上先完成 **IPTV 网络融合**，让 HA 主机所在的 VLAN 能获取到 IPTV 内网 IP 并接收到组播流。

---

## 安装

1. 进入 **设置 → 加载项 → 加载项商店**
2. 点击右上角菜单 → **仓库** → 添加：`https://github.com/wuwweizn/wwzn-china`
3. 刷新后找到 **rtp2httpd** → 点击安装
4. 安装完成后进入加载项页面，按需修改配置后点击 **启动**
5. 点击 **打开 Web UI** 进入状态监控后台

---

## 配置项说明

### 基础配置

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `listen_port` | `5140` | HTTP 监听端口，IPTV 播放和 Web 后台共用此端口 |
| `max_clients` | `20` | 最大同时连接客户端数 |
| `verbose` | `2` | 日志级别：0=静默 1=错误 2=警告 3=信息 4=调试 |
| `workers` | `1` | 工作进程数，多核设备可适当调高 |

### 网络配置

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `upstream_interface` | `""` | 上游网络接口名，留空则使用系统路由。多网卡时指定接收组播的接口，如 `eth0`、`br-iptv` |

### M3U 播放列表

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `external_m3u` | `""` | 外部 M3U 地址，支持 `http://`、`https://`、`file://` 协议。加载后可通过 `/playlist.m3u` 访问转换后的列表 |
| `external_m3u_update_interval` | `7200` | M3U 自动更新间隔（秒），设为 `0` 禁用自动更新 |

### FCC 快速换台

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `fcc_listen_port_range` | `""` | FCC UDP 监听端口范围，格式 `40000-40100`。留空则随机端口 |

### 安全配置

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `r2h_token` | `""` | 访问认证令牌，设置后所有请求 URL 必须带 `?r2h-token=xxx`。留空不启用 |

### 高级配置

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `extra_args` | `""` | 传递给 rtp2httpd 的额外命令行参数，如 `--zerocopy-on-send --workers 2` |

---

## 使用配置文件（推荐用于复杂场景）

如果需要配置 **内联 M3U 频道列表**、**多网口绑定**、**回看/时移**、**EPG** 等高级功能，建议使用配置文件。

将配置文件保存到以下路径（通过 Samba 或 SSH 访问）：

```
/addon_configs/rtp2httpd/rtp2httpd.conf
```

**配置文件存在时，加载项选项中的参数将全部被忽略，完全由配置文件控制。**

### 最小配置文件示例

```ini
[global]
verbosity = 3
maxclients = 20
workers = 1

[bind]
* 5140

[services]
#EXTM3U
#EXTINF:-1 tvg-name="CCTV1" group-title="央视",CCTV-1
rtp://239.x.x.x:xxxx
#EXTINF:-1 tvg-name="CCTV2" group-title="央视",CCTV-2
rtp://239.x.x.x:xxxx
```

### 含外部 M3U + FCC 完整示例

```ini
[global]
verbosity = 2
maxclients = 20
workers = 1
upstream-interface = eth0
external-m3u = http://192.168.1.1/iptv.m3u
external-m3u-update-interval = 3600
fcc-listen-port-range = 40000-40100

[bind]
* 5140
```

完整参数说明：[rtp2httpd.com/reference/configuration](https://rtp2httpd.com/reference/configuration)

---

## 访问地址速查

加载项启动后，将 `<HA主机IP>` 替换为你的实际 IP（端口默认 `5140`）：

| 功能 | 地址 |
|------|------|
| Web 状态后台 | `http://<HA主机IP>:5140/status` |
| 内置 Web 播放器 | `http://<HA主机IP>:5140/player` （需先配置 M3U）|
| 转换后的 M3U 播放列表 | `http://<HA主机IP>:5140/playlist.m3u` （需先配置 M3U）|
| RTP 组播转 HTTP | `http://<HA主机IP>:5140/rtp/239.x.x.x:xxxx` |
| udpxy 兼容格式 | `http://<HA主机IP>:5140/udp/239.x.x.x:xxxx` |

---

## 常见问题

**Q：日志显示启动成功但收不到流？**

说明主机网络环境无法接收 IPTV 组播包。请先确认路由器已完成 IPTV 融合，并检查 `upstream_interface` 是否指向正确的网口。

**Q：有多张网卡，用哪个接口？**

在 HA 的 SSH 终端执行 `ip addr` 查看网卡名称，将接收 IPTV 组播的那张网卡名填入 `upstream_interface`，如 `eth0`。

**Q：如何配置 M3U 播放列表让播放器使用？**

在 `external_m3u` 中填入你的 M3U 地址（支持运营商 IPTV 的 M3U），启动后播放器使用 `http://<HA主机IP>:5140/playlist.m3u` 这个转换后的地址，rtp2httpd 会自动把里面的组播地址替换为 HTTP 地址。

**Q：如何启用 FCC 快速换台？**

填写 `fcc_listen_port_range`（如 `40000-40100`），并在 M3U 频道的 URL 后追加 FCC 服务器地址参数，详见：[FCC 快速换台配置](https://rtp2httpd.com/guide/fcc-setup)

**Q：如何更新到新版本？**

修改 `config.yaml` 中的 `version` 字段为新版本号，推送到仓库后 GitHub Actions 自动构建，完成后在 HA 中重新安装加载项即可。

---

## 相关链接

- [URL 格式说明](https://rtp2httpd.com/guide/url-formats)
- [M3U 播放列表集成](https://rtp2httpd.com/guide/m3u-integration)
- [FCC 快速换台配置](https://rtp2httpd.com/guide/fcc-setup)
- [各地 FCC 地址汇总](https://rtp2httpd.com/reference/cn-fcc-collection)
- [配置参数详解](https://rtp2httpd.com/reference/configuration)
- [性能测试报告](https://rtp2httpd.com/reference/benchmark)
