## 使用指南

### 快速开始

1. **安装加载项**
   - 在Home Assistant加载项商店中找到"Clash Proxy"
   - 点击安装

2. **基本配置**
   ```yaml
   subscription_url: "https://your-airport.com/subscription-link"
   auto_update: true
   update_interval: 86400
   secret: "your-web-ui-password"
   ```

3. **启动加载项**
   - 点击"启动"
   - 等待启动完成

4. **访问Web界面**
   - 点击"打开Web UI"
   - 或访问 `http://homeassistant-ip:9090/ui`

### 机场订阅配置

#### 直接使用Clash订阅
如果你的机场支持Clash格式订阅：
```yaml
subscription_url: "https://example.com/clash/subscription"
```

#### 使用订阅转换
如果机场只提供其他格式（如v2ray、shadowsocks）：
```yaml
subscription_url: "https://api.dler.io/sub?target=clash&url=你的原始订阅链接"
```

#### 多订阅合并
如果有多个机场订阅：
```yaml
subscription_url: "https://api.dler.io/sub?target=clash&url=订阅1|订阅2&emoji=true"
```

### Web界面使用

1. **初次访问**
   - 如果设置了secret，需要输入密码
   - 进入主界面

2. **选择节点**
   - 点击"代理"标签页
   - 在"🚀 手动切换"组中选择节点
   - 可以点击闪电图标测试延迟

3. **查看连接**
   - "连接"标签页显示实时连接
   - 可以查看具体哪些应用在使用代理

4. **规则管理**
   - "规则"标签页查看分流规则
   - 可以看到哪些域名走直连/代理

### 设备代理配置

#### Windows
1. 设置 → 网络和Internet → 代理
2. 手动设置代理：
   - 地址：`homeassistant-ip`
   - 端口：`7890`

#### macOS
1. 系统偏好设置 → 网络 → 高级 → 代理
2. 勾选"Web代理(HTTP)"
3. 服务器：`homeassistant-ip`，端口：`7890`

#### 移动设备
- Android/iOS WiFi设置中配置HTTP代理
- 地址：`homeassistant-ip:7890`

#### 浏览器插件
推荐使用SwitchyOmega：
- 新建情景模式
- 协议：HTTP
- 服务器：`homeassistant-ip`
- 端口：`7890`

## 高级功能

### 自定义规则

编辑 `/config/clash/config.yaml` 添加自定义规则：

```yaml
rules:
  # 特定域名走代理
  - DOMAIN-SUFFIX,google.com,🚀 手动切换
  # 特定应用直连  
  - PROCESS-NAME,WeChat.exe,🎯 全球直连
  # IP段规则
  - IP-CIDR,192.168.0.0/16,🎯 全球直连
```

### 代理组配置

```yaml
proxy-groups:
  - name: "🚀 手动切换"
    type: select
    proxies:
      - "🇺🇸 美国节点"
      - "🇯🇵 日本节点"
      - DIRECT
      
  - name: "🇺🇸 美国节点"
    type: url-test
    url: 'http://www.gstatic.com/generate_204'
    interval: 300
    proxies:
      - "美国-节点1"
      - "美国-节点2"
```

### DNS配置优化

```yaml
dns:
  enable: true
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  nameserver:
    - 119.29.29.29  # 国内DNS
    - 223.5.5.5
  fallback:
    - 8.8.8.8      # 国外DNS
    - 1.1.1.1
```

## 故障排除

### 常见问题

1. **订阅更新失败**
   - 检查订阅链接是否有效
   - 尝试使用订阅转换服务
   - 查看加载项日志获取详细错误

2. **节点连接超时**
   - 在Web界面测试节点延迟
   - 尝试切换其他节点
   - 检查网络连接状态

3. **Web界面无法访问**
   - 确认加载项已启动
   - 检查端口9090是否被占用
   - 尝试重启加载项

4. **代理不生效**
   - 确认设备代理配置正确
   - 检查Clash是否正在运行
   - 查看连接页面确认流量经过

### 调试技巧

1. **启用详细日志**
   ```yaml
   log_level: debug
   ```

2. **检查配置语法**
   - 使用在线YAML验证器
   - 查看启动日志中的错误信息

3. **网络连通性测试**
   ```bash
   # 测试代理端口
   telnet homeassistant-ip 7890
   
   # 测试管理端口
   curl http://homeassistant-ip:9090/version
   ```

## 与XRay的对比

| 特性 | Clash | XRay |
|------|-------|------|
| Web界面 | ✅ 内置 | ❌ 无 |
| 订阅支持 | ✅ 原生 | ❌ 需手动 |
| 规则分流 | ✅ 强大 | ✅ 灵活 |
| 性能 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| 配置难度 | 简单 | 复杂 |
| 适用场景 | 日常使用 | 高级用户 |

## 建议

- **新手用户**：推荐使用Clash，界面友好，配置简单
- **高级用户**：可以根据需求选择XRay或Clash
- **家庭网关**：Clash更适合作为家庭网络的代理网关

现在你就有了一个功能完整的Clash Home Assistant加载项！