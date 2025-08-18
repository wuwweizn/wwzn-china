# Clash Home Assistant Add-on

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armv7 Architecture][armv7-shield]

Clash是一个基于规则的代理工具，支持订阅链接和可视化Web管理界面。

注意：本加载项仅可在官方HA固件使用。部分加速版的ha无法使用

## 关于

Clash是一个现代化的代理工具，支持多种协议（Shadowsocks、VMess、Trojan等），具有强大的规则分流功能和友好的Web界面。

## 功能特性

- 🌐 **支持多种协议**：Shadowsocks、VMess、Trojan、HTTP等
- 📱 **Web可视化界面**：直观的节点管理和规则配置
- 🔄 **订阅链接支持**：自动更新机场节点
- 🎯 **智能分流**：基于规则的流量分流
- 📊 **实时监控**：流量统计和连接管理
- 🚀 **高性能**：原生Go语言编写，性能优异

## 安装

1. 在Home Assistant中添加此存储库：
   ```
   https://github.com/wuwweizn/wwzn-china
   ```

2. 从Add-on Store安装Clash加载项

3. 配置订阅链接（可选）

4. 启动加载项

## 配置

### 基本选项

| 选项 | 描述 | 默认值 |
|------|------|--------|
| `log_level` | 日志级别 | `info` |
| `external_controller` | 管理API地址 | `0.0.0.0:9090` |
| `secret` | API访问密钥（可选） | `""` |
| `subscription_url` | 机场订阅链接 | `""` |
| `update_interval` | 订阅更新间隔（秒） | `86400` |
| `auto_update` | 自动更新订阅 | `true` |

### 端口配置

- **7890**: HTTP代理端口
- **7891**: SOCKS代理端口
- **9090**: Web管理界面

## 使用方法

### 1. 配置机场订阅

在加载项配置中填入你的机场订阅链接：

```yaml
界面访问密码设置 secret：123456（可选）
订阅连接配置 subscription_url: "https://your-airport.com/link/xxxxx"
update_interval: 86400
auto_update: true
```

### 2. 访问Web界面

启动后浏览器访问：`http://homeassistant-ip:9090/ui` 如：http://192.168.2.33:9090/ui
或在Home Assistant中点击"打开Web UI"

API Base URL：homeassistant-ip:9090（ha地址+端口）
Secret(optional)：123456（配置页中的密码）
Add(添加)--并进入clash页面

### 3. 选择代理节点

在Web界面中：
1. 选择"代理"标签页
2. 在"🚀 手动切换"组中选择节点
3. 查看连接状态和延迟测试

### 4. 配置设备代理

在设备上配置代理：
- HTTP代理：`homeassistant-ip:7890`
- SOCKS代理：`homeassistant-ip:7891`

## 高级配置

### 手动编辑配置文件

配置文件位置：`/config/clash/config.yaml`

可以通过File Editor加载项编辑，支持：
- 自定义代理组
- 规则分流设置  
- DNS配置
- 节点延迟测试

### 订阅转换

如果机场不支持Clash订阅，可以使用订阅转换服务：
- `https://sub.xeton.dev`

示例：
```
https://sub.xeton.dev?target=clash&url=你的原始订阅链接
```

## 代理规则

默认规则集包括：
- 🎯 **国内直连**：中国大陆网站和IP直连
- 🚀 **海外代理**：被墙网站使用代理
- 🛑 **广告拦截**：屏蔽广告和追踪域名
- 📺 **流媒体**：Netflix、YouTube等分流

## 故障排除

### 1. 订阅更新失败
- 检查订阅链接是否正确
- 查看加载项日志获取错误信息
- 尝试手动更新订阅

### 2. 节点连接失败
- 在Web界面测试节点延迟
- 检查节点是否可用
- 尝试切换其他节点

### 3. Web界面无法访问
- 确认端口9090未被占用
- 检查防火墙设置
- 重启加载项

### 4. 代理不生效
- 确认设备代理配置正确
- 检查代理端口7890/7891
- 查看Clash日志确认连接状态

## 配置示例

### 基本配置
```yaml
log_level: info
external_controller: "0.0.0.0:9090"
secret: "your-secret-key"
subscription_url: "https://your-airport.com/subscription"
update_interval: 86400
auto_update: true
```

### 多订阅合并
如果有多个机场订阅，可以使用订阅转换服务合并：
```
https://sub.xeton.dev?target=clash&url=订阅1|订阅2|订阅3
```

## Web界面功能

### 概览页面
- 实时速度监控
- 活跃连接数
- 上传下载统计

### 代理页面
- 节点延迟测试
- 代理组切换
- 节点连接状态

### 规则页面
- 规则匹配统计
- 自定义规则添加
- 规则优先级调整

### 连接页面
- 实时连接监控
- 连接详细信息
- 手动断开连接

### 日志页面
- 实时日志查看
- 日志级别筛选
- 错误信息追踪

## 性能优化

### DNS配置优化
```yaml
dns:
  enable: true
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  nameserver:
    - https://doh.pub/dns-query
    - https://dns.alidns.com/dns-query
```

### 规则优化
- 将常用网站规则放在前面
- 使用域名规则而非正则表达式
- 定期更新规则集

## 安全建议

1. **设置API密钥**：保护Web管理界面
2. **限制访问IP**：仅允许内网访问
3. **定期更新**：保持软件版本最新
4. **监控日志**：关注异常连接

## 更新日志

### v1.18.0
- 支持订阅链接自动更新
- 集成Web管理界面
- 优化规则分流逻辑
- 添加延迟测试功能

## 支持

如果遇到问题，请：

1. 查看加载项日志获取错误信息
2. 访问Clash官方文档了解配置语法
3. 在GitHub仓库提交Issue

GitHub仓库：https://github.com/wuwweizn/wwzn-china/issues

## 许可证

本项目基于GPL-3.0许可证开源。

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg