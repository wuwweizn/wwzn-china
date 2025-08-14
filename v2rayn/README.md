# Home Assistant v2rayN 加载项

![支持 aarch64 架构][aarch64-shield]
![支持 amd64 架构][amd64-shield]
![支持 armhf 架构][armhf-shield]
![支持 armv7 架构][armv7-shield]
![支持 i386 架构][i386-shield]

v2rayN代理客户端集成到Home Assistant，提供安全灵活的代理服务和Web界面管理。

## 关于

v2rayN是一个功能强大的V2Ray/Xray客户端，支持多种协议包括VMess、VLESS、Trojan、Shadowsocks等。这个Home Assistant加载项将v2rayN功能直接集成到你的Home Assistant实例中，允许你：

- 通过各种代理协议路由流量
- 管理多个代理服务器
- 配置高级路由规则
- 监控连接统计信息
- 通过Web界面访问管理

## 安装步骤

1. 在Home Assistant中导航到"监督程序"
2. 点击"加载项商店"
3. 添加此仓库URL：`https://github.com/wuwweizn/wwzn-china`
4. 在加载项商店中找到"v2rayN"并点击"安装"
5. 启动加载项

## 配置说明

### 基础配置

```yaml
log_level: info
http_port: 10808
socks_port: 10809
api_port: 8080
allow_lan: true
enable_sniffing: true
enable_routing: true
dns:
  enable: true
  servers:
    - "https://1.1.1.1/dns-query"
    - "https://8.8.8.8/dns-query"
servers: []
```

### 配置选项说明

| 选项 | 描述 | 默认值 | 类型 |
|------|------|--------|------|
| `log_level` | 应用程序日志级别 | `info` | `trace`/`debug`/`info`/`warning`/`error`/`fatal` |
| `http_port` | HTTP代理监听端口 | `10808` | 整数 |
| `socks_port` | SOCKS代理监听端口 | `10809` | 整数 |
| `api_port` | API和Web界面端口 | `8080` | 整数 |
| `allow_lan` | 允许局域网连接 | `true` | 布尔值 |
| `enable_sniffing` | 启用流量嗅探 | `true` | 布尔值 |
| `enable_routing` | 启用高级路由 | `true` | 布尔值 |
| `dns.enable` | 启用DNS服务器 | `true` | 布尔值 |
| `dns.servers` | DNS服务器列表 | 见示例 | 列表 |
| `servers` | 代理服务器配置 | `[]` | 列表 |

### 服务器配置

要添加代理服务器，请配置`servers`选项：

```yaml
servers:
  - name: "我的VMess服务器"
    type: "vmess"
    server: "example.com"
    port: 443
    uuid: "你的UUID"
    alterId: 0
    security: "auto"
    network: "ws"
    tls: true
    path: "/path"
    host: "example.com"
  - name: "我的Trojan服务器"
    type: "trojan"
    server: "trojan.example.com"
    port: 443
    password: "你的密码"
    sni: "trojan.example.com"
    tls: true
```

## 使用说明

### Web界面

启动加载项后，通过以下地址访问Web界面：
- **本地**: `http://homeassistant.local:8080`
- **IP地址**: `http://你的HA_IP:8080`

### 代理设置

配置你的应用程序使用代理：
- **HTTP代理**: `http://你的HA_IP:10808`
- **SOCKS5代理**: `socks5://你的HA_IP:10809`

### Home Assistant集成

代理可以被Home Assistant本身使用，通过在`configuration.yaml`中配置：

```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 127.0.0.1
    - 你的HA_IP
```

## 高级功能

### 路由规则

当启用`enable_routing`时，加载项会自动配置：
- 私有IP范围的直连访问
- 基于域名的路由规则
- 自定义路由策略

### DNS配置

支持DNS over HTTPS (DoH)，可配置上游服务器：
- Cloudflare: `https://1.1.1.1/dns-query`
- Google: `https://8.8.8.8/dns-query`
- Quad9: `https://9.9.9.9/dns-query`

### 统计和监控

加载项通过以下方式提供连接统计：
- Web界面仪表板
- API端点
- 日志分析

## 故障排除

### 常见问题

1. **连接失败**
   - 检查服务器配置
   - 验证网络连通性
   - 查看日志中的错误消息

2. **端口冲突**
   - 确保端口未被其他服务占用
   - 检查Home Assistant端口分配
   - 根据需要修改端口配置

3. **权限错误**
   - 重启加载项
   - 检查Home Assistant监督程序日志
   - 验证加载项权限

### 日志分析

通过以下方式访问日志：
- Home Assistant中的加载项日志
- `/share/v2rayn/logs/`目录
- Web界面日志查看器

### 配置验证

加载项在启动时验证配置：
- JSON语法检查
- 端口冲突检测
- 服务器可达性测试

## 安全考虑

- 可用时始终使用TLS加密
- 定期更新代理服务器配置
- 监控连接日志以发现可疑活动
- 使用强身份验证方法

## 备份和恢复

### 自动备份

配置备份会自动创建：
- 位置: `/share/v2rayn/backups/`
- 频率: 每次配置更改前
- 格式: `config_YYYYMMDD_HHMMSS.json`

### 手动备份

```bash
# 访问加载项终端
v2rayn-manager.sh backup
```

### 恢复配置

```bash
# 从备份恢复
v2rayn-manager.sh restore /share/v2rayn/backups/config_20231201_120000.json
```

## 性能调优

### 资源使用

- **内存**: 典型使用64-128 MB
- **CPU**: 正常运行期间低影响
- **网络**: 取决于代理流量量

### 优化建议

1. **降低日志详细度**用于生产环境
2. **禁用不必要功能**（嗅探、路由）
3. **使用高效协议**（VLESS优于VMess）
4. **配置适当超时**

## 支持

如有问题和功能请求：
- GitHub Issues: [https://github.com/wuwweizn/wwzn-china/issues](https://github.com/wuwweizn/wwzn-china/issues)
- Home Assistant社区: [社区论坛](https://community.home-assistant.io/)

## 贡献

欢迎贡献！请查看我们的贡献指南了解详情。

## 许可证

此加载项采用MIT许可证。详见LICENSE文件。

---

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg