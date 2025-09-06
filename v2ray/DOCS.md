# V2Ray Home Assistant 加载项使用指南

## 🎉 成功启动确认

当您看到以下日志信息时，说明 V2Ray 已成功启动：
```
Configuration OK.
INFO: Starting V2Ray...
V2Ray 5.24.0 started
```

## 📋 代理服务信息

V2Ray 启动后会提供两种代理服务：

| 协议类型 | 地址 | 端口 | 用途 |
|---------|------|------|------|
| SOCKS5 | `127.0.0.1` | `10808` | 支持 TCP/UDP，推荐使用 |
| HTTP | `127.0.0.1` | `10809` | 仅支持 TCP |

## 🔧 客户端配置方法

### 1. 浏览器代理设置

#### Chrome/Edge 浏览器
1. 安装 SwitchyOmega 扩展
2. 创建新的代理配置：
   - **协议**：SOCKS5
   - **服务器**：`127.0.0.1`
   - **端口**：`10808`
3. 应用配置并启用

#### Firefox 浏览器
1. 设置 → 网络设置 → 手动代理配置
2. 配置信息：
   - **SOCKS 主机**：`127.0.0.1`
   - **端口**：`10808`
   - **SOCKS v5**：✅ 勾选
   - **使用 SOCKS v5 代理 DNS**：✅ 勾选

### 2. Windows 系统代理

#### 方法一：系统设置（仅 HTTP）
1. Windows 设置 → 网络和 Internet → 代理
2. 手动设置代理：
   - **地址**：`127.0.0.1`
   - **端口**：`10809`

#### 方法二：使用 Proxifier（推荐）
1. 下载安装 Proxifier
2. Profile → Proxy Servers → Add
3. 配置信息：
   - **地址**：`127.0.0.1`
   - **端口**：`10808`
   - **协议**：SOCKS Version 5

### 3. macOS 系统代理

#### 系统偏好设置
1. 系统偏好设置 → 网络 → 高级 → 代理
2. 勾选 **SOCKS 代理**
3. 配置信息：
   - **SOCKS 代理服务器**：`127.0.0.1:10808`

### 4. Android 设备

#### 使用 Postern 应用
1. 安装 Postern 应用
2. 添加代理：
   - **类型**：socks5
   - **主机**：`127.0.0.1`
   - **端口**：`10808`

### 5. iOS 设备

#### 使用 Shadowrocket 或类似应用
1. 添加代理配置
2. 配置信息：
   - **类型**：SOCKS5
   - **服务器**：`127.0.0.1`
   - **端口**：`10808`

## 🔄 Home Assistant 内部应用代理

### Node-RED 代理设置
```javascript
// 在 Node-RED 的 HTTP Request 节点中
msg.proxy = "http://127.0.0.1:10809";
```

### Home Assistant 集成代理
某些集成支持代理设置，可在配置中添加：
```yaml
# configuration.yaml 示例
some_integration:
  proxy: "socks5://127.0.0.1:10808"
```

## 📊 监控和管理

### 查看运行状态
1. Home Assistant → Supervisor → V2Ray Core
2. 查看 **日志** 标签页了解运行状态
3. 查看 **信息** 标签页了解资源使用情况

### 配置更新
1. 修改配置后点击 **重启**
2. 系统会自动重新下载订阅并重启服务

### 手动更新订阅
1. 重启加载项即可触发订阅更新
2. 或等待自动更新（默认24小时）

## 🛠️ 高级配置

### 自定义端口
如果端口冲突，可在配置页面修改：
- `socks_port`: SOCKS5 代理端口
- `http_port`: HTTP 代理端口

### 日志级别调整
- `debug`: 详细调试信息
- `info`: 一般信息
- `warning`: 警告信息（推荐）
- `error`: 仅错误信息
- `none`: 不输出日志

### 更新频率设置
- `update_interval`: 订阅更新间隔（小时）
- 建议设置 12-72 小时之间

## 🚨 故障排除

### 1. 无法连接代理
**检查项目**：
- [ ] V2Ray 加载项是否正常运行
- [ ] 代理端口配置是否正确
- [ ] Home Assistant 所在设备防火墙设置
- [ ] 客户端是否能访问 Home Assistant IP

**解决方法**：
```bash
# 测试代理连通性（在 Home Assistant 终端中）
curl -x socks5://127.0.0.1:10808 http://www.google.com
```

### 2. 订阅解析失败
**可能原因**：
- 订阅链接已失效
- 网络连接问题
- 订阅格式不支持

**解决方法**：
- 检查订阅链接是否能正常访问
- 查看日志中的具体错误信息
- 联系订阅服务提供商

### 3. 节点连接失败
**检查项目**：
- [ ] 订阅中的节点是否正常
- [ ] 本地网络是否正常
- [ ] 是否需要更新订阅

## 💡 使用技巧

### 1. 测试代理是否正常工作
访问以下网站检查代理效果：
- https://whatismyipaddress.com/
- https://www.whatismyip.com/
- https://ipinfo.io/

### 2. 优化代理性能
- 选择地理位置较近的节点
- 定期更新订阅获取最新节点
- 根据使用场景选择合适的协议

### 3. 安全建议
- 定期更新 V2Ray 版本
- 不要在公共网络上暴露代理端口
- 使用强密码保护 Home Assistant

## 📞 技术支持

### 获取帮助
1. **查看日志**：Supervisor → V2Ray Core → 日志
2. **GitHub Issues**：前往项目仓库报告问题
3. **Home Assistant 社区**：发帖寻求帮助

### 常用命令
```bash
# 在 Home Assistant SSH 终端中测试
# 测试 SOCKS5 代理
curl -x socks5://127.0.0.1:10808 https://httpbin.org/ip

# 测试 HTTP 代理  
curl -x http://127.0.0.1:10809 https://httpbin.org/ip

# 查看进程状态
ps aux | grep v2ray
```

---

## 🎯 快速开始总结

1. ✅ **确认服务运行**：查看日志确保 V2Ray 启动成功
2. 🌐 **配置浏览器**：使用 SwitchyOmega 或系统代理设置
3. 📱 **移动设备**：使用专用代理应用配置 SOCKS5 代理
4. 🔍 **测试连接**：访问 IP 查询网站验证代理效果
5. 📊 **监控状态**：定期查看加载项日志和状态

现在您已经可以正常使用 V2Ray 代理服务了！🚀