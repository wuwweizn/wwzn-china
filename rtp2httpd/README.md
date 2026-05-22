# rtp2httpd Home Assistant 加载项

IPTV 组播转单播转发服务器，支持将组播 RTP/UDP 流、RTSP 流转换为 HTTP 单播流，内置 Web 播放器、状态监控面板与快速换台（FCC）功能。

官方项目：[https://github.com/stackia/rtp2httpd](https://github.com/stackia/rtp2httpd)

---

## 前提条件

> **重要**：rtp2httpd 需要能够接收到运营商 IPTV 组播网络的数据包。
> 在使用本加载项之前，你的网络环境必须满足以下条件之一：
>
> - 你的 Home Assistant 主机通过支持 IPTV 的路由器（如已完成 IPTV 融合的 OpenWrt）连接到内网，可以直接收到 IPTV 组播流
> - 你的主机所在网段本身已通过 DHCP 鉴权获取了 IPTV 内网 IP

---

## 安装

1. 在 Home Assistant 中，进入 **设置 → 加载项 → 加载项商店**
2. 点击右上角菜单 → **仓库**
3. 添加仓库地址：`https://github.com/wuwweizn/wwzn-china`
4. 刷新后找到 **rtp2httpd**，点击安装
5. 安装完成后，点击 **启动**

---

## 配置说明

在加载项的 **配置** 选项卡中可以修改以下参数：

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `listen_port` | `5140` | rtp2httpd 监听的 HTTP 端口，IPTV 播放地址和 Web 后台都使用此端口 |
| `max_clients` | `20` | 最大同时连接客户端数量 |
| `verbose` | `2` | 日志详细程度，0=静默，1=错误，2=信息，3=调试 |
| `extra_args` | `""` | 传递给 rtp2httpd 的额外命令行参数，留空即可 |

### 使用配置文件（可选）

如果需要使用完整的配置文件（例如配置 FCC、M3U 播放列表、多网口绑定等高级功能），可以将配置文件放到以下路径：

```
/addon_configs/rtp2httpd/rtp2httpd.conf
```

配置文件存在时，加载项会忽略上方的参数配置，改用配置文件启动。

配置文件示例可参考：[rtp2httpd.conf 示例](https://github.com/stackia/rtp2httpd/blob/main/rtp2httpd.conf)

完整参数说明：[配置参数详解](https://rtp2httpd.com/reference/configuration)

---

## 访问 Web 后台

加载项启动后，点击加载项页面的 **打开 Web UI** 按钮，或直接在浏览器访问：

```
http://<HA主机IP>:5140/status
```

Web 后台功能：
- 查看实时连接状态与带宽使用
- 查看和动态调整日志
- 强制断开客户端连接
- 内置播放器入口（需先配置 M3U 播放列表）

---

## 使用 IPTV 播放

### 直接播放组播地址

将 IPTV 频道的组播地址（如 `rtp://239.x.x.x:xxxx`）转换为 HTTP 地址，格式如下：

```
# RTP/UDP 组播转 HTTP
http://<HA主机IP>:5140/rtp/239.x.x.x:xxxx

# 兼容 udpxy 格式
http://<HA主机IP>:5140/udp/239.x.x.x:xxxx
```

### 配置 M3U 播放列表

在配置文件中设置 M3U 源后，可通过以下地址获取转换后的播放列表：

```
http://<HA主机IP>:5140/playlist.m3u
```

将此地址填入 IPTV 播放器（如 mytv-android、TiviMate 等）即可使用。

### 内置 Web 播放器

配置 M3U 后，浏览器访问以下地址可使用内置播放器：

```
http://<HA主机IP>:5140/player
```

---

## 常见问题

**Q：加载项启动了但收不到任何频道的流？**

A：说明你的 HA 主机网络环境无法收到 IPTV 组播包。需要先在路由器侧完成 IPTV 网络融合，确保主机所在 VLAN 能收到组播流。可以用以下命令测试：
```bash
# 在 HA 主机上执行，能收到数据说明组播通
tcpdump -i any udp and host 239.x.x.x
```

**Q：如何查看日志排查问题？**

A：在加载项页面点击 **日志** 选项卡，或将 `verbose` 调整为 `3` 获取更详细的调试日志。

**Q：如何更新到新版本？**

A：修改 `config.yaml` 中的 `version` 字段为新版本号，推送到仓库后重新触发 GitHub Actions 构建，构建完成后在 HA 中重新安装加载项即可。

---

## 网络端口说明

| 端口 | 协议 | 用途 |
|------|------|------|
| 5140 | TCP | IPTV HTTP 流播放 + Web 管理后台 |

加载项使用 **host 网络模式**运行（接收组播流的必要条件），因此端口直接暴露在宿主机网络上。

---

## 相关链接

- [rtp2httpd 官方文档](https://rtp2httpd.com)
- [配置参数详解](https://rtp2httpd.com/reference/configuration)
- [URL 格式说明](https://rtp2httpd.com/guide/url-formats)
- [M3U 播放列表集成](https://rtp2httpd.com/guide/m3u-integration)
- [FCC 快速换台配置](https://rtp2httpd.com/guide/fcc-setup)
- [各地 FCC 地址汇总](https://rtp2httpd.com/reference/cn-fcc-collection)
