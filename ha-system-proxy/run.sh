#!/usr/bin/with-contenv bashio
# ha-system-proxy/run.sh

# 读取配置
PROXY_MODE=$(bashio::config 'proxy_mode')
V2RAY_HOST=$(bashio::config 'v2ray_host')
SOCKS_PORT=$(bashio::config 'v2ray_socks_port')
HTTP_PORT=$(bashio::config 'v2ray_http_port')
ENABLE_SYSTEM_PROXY=$(bashio::config 'enable_system_proxy')
BYPASS_PRIVATE=$(bashio::config 'bypass_private_networks')
TEST_CONNECTIVITY=$(bashio::config 'test_connectivity')

bashio::log.info "🚀 Starting HA System Proxy..."
bashio::log.info "📋 Proxy mode: ${PROXY_MODE}"
bashio::log.info "🌐 V2Ray host: ${V2RAY_HOST}"
bashio::log.info "🌐 SOCKS5 port: ${SOCKS_PORT}"
bashio::log.info "🌐 HTTP port: ${HTTP_PORT}"

if [ "${PROXY_MODE}" = "disabled" ]; then
    bashio::log.info "🔄 Proxy mode disabled"
    exec sleep infinity
fi

# 检查网络连通性
bashio::log.info "🔍 Checking network connectivity..."
bashio::log.info "Local IP addresses:"
ip addr show | grep "inet " | sed 's/^/  /'

# 尝试不同的 V2Ray 地址
POSSIBLE_HOSTS=("${V2RAY_HOST}" "172.30.33.0" "supervisor" "homeassistant.local")

V2RAY_AVAILABLE=""
for host in "${POSSIBLE_HOSTS[@]}"; do
    bashio::log.info "🔍 Trying V2Ray at ${host}:${SOCKS_PORT}..."
    if timeout 5 nc -z "${host}" "${SOCKS_PORT}" 2>/dev/null; then
        bashio::log.info "✅ Found V2Ray at ${host}:${SOCKS_PORT}"
        V2RAY_AVAILABLE="${host}"
        break
    else
        bashio::log.warning "❌ Cannot connect to ${host}:${SOCKS_PORT}"
    fi
done

if [ -z "${V2RAY_AVAILABLE}" ]; then
    bashio::log.error "❌ Cannot find V2Ray addon on any host"
    bashio::log.error "💡 Please ensure:"
    bashio::log.error "   1. V2Ray addon is running"
    bashio::log.error "   2. V2Ray addon has proper port mapping"
    bashio::log.error "   3. Check V2Ray addon logs for errors"
    exit 1
fi

# 等待 V2Ray 加载项完全启动
bashio::log.info "⏳ Waiting for V2Ray addon to be fully ready..."
for i in {1..15}; do
    if curl -s --connect-timeout 3 --socks5 "${V2RAY_AVAILABLE}:${SOCKS_PORT}" https://www.google.com > /dev/null 2>&1; then
        bashio::log.info "✅ V2Ray addon is fully ready"
        break
    fi
    if [ $i -eq 15 ]; then
        bashio::log.warning "⚠️ V2Ray addon responds but proxy test failed"
        bashio::log.warning "   This might be normal if V2Ray is still initializing"
        break
    fi
    sleep 3
done

# 构建代理配置
PROXY_HTTP="http://${V2RAY_AVAILABLE}:${HTTP_PORT}"
PROXY_SOCKS="socks5://${V2RAY_AVAILABLE}:${SOCKS_PORT}"

# 构建 no_proxy 列表
NO_PROXY="localhost,127.0.0.1,::1,supervisor,homeassistant.local"
if bashio::var.true "${BYPASS_PRIVATE}"; then
    NO_PROXY="${NO_PROXY},10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,fd00::/8"
fi

bashio::log.info "🔧 Configuring system proxy..."

# 设置环境变量
export http_proxy="${PROXY_HTTP}"
export https_proxy="${PROXY_HTTP}"
export HTTP_PROXY="${PROXY_HTTP}"
export HTTPS_PROXY="${PROXY_HTTP}"
export no_proxy="${NO_PROXY}"
export NO_PROXY="${NO_PROXY}"

# 创建代理配置文件供其他进程使用
cat > /tmp/proxy_config << EOF
http_proxy=${PROXY_HTTP}
https_proxy=${PROXY_HTTP}
no_proxy=${NO_PROXY}
socks_proxy=${PROXY_SOCKS}
v2ray_host=${V2RAY_AVAILABLE}
EOF

bashio::log.info "📋 Proxy configuration:"
bashio::log.info "  🔹 V2Ray Host: ${V2RAY_AVAILABLE}"
bashio::log.info "  🔹 HTTP Proxy: ${PROXY_HTTP}"
bashio::log.info "  🔹 SOCKS5 Proxy: ${PROXY_SOCKS}"
bashio::log.info "  🔹 No Proxy: ${NO_PROXY}"

# 测试代理连通性
if bashio::var.true "${TEST_CONNECTIVITY}"; then
    bashio::log.info "🧪 Testing proxy connectivity..."
    
    # 测试 SOCKS5 代理
    bashio::log.info "  🔄 Testing SOCKS5 proxy..."
    SOCKS_IP=$(timeout 10 curl -s --socks5 "${PROXY_SOCKS}" https://httpbin.org/ip 2>/dev/null | jq -r '.origin' 2>/dev/null || echo "Failed")
    bashio::log.info "  🌍 SOCKS5 IP: ${SOCKS_IP}"
    
    # 测试 HTTP 代理 (使用更宽松的超时)
    bashio::log.info "  🔄 Testing HTTP proxy..."
    HTTP_IP=$(timeout 15 curl -s --proxy "${PROXY_HTTP}" https://httpbin.org/ip 2>/dev/null | jq -r '.origin' 2>/dev/null || echo "Failed")
    if [ "${HTTP_IP}" = "Failed" ]; then
        # 尝试不同的测试 URL
        HTTP_IP=$(timeout 10 curl -s --proxy "${PROXY_HTTP}" http://httpbin.org/ip 2>/dev/null | jq -r '.origin' 2>/dev/null || echo "Failed")
    fi
    bashio::log.info "  🌐 HTTP IP: ${HTTP_IP}"
    
    if [ "${SOCKS_IP}" != "Failed" ] && [ "${HTTP_IP}" != "Failed" ]; then
        bashio::log.info "  ✅ Both proxy types working correctly"
    elif [ "${SOCKS_IP}" != "Failed" ]; then
        bashio::log.info "  ✅ SOCKS5 proxy working (recommended for most use cases)"
        bashio::log.warning "  ⚠️ HTTP proxy not working, but this is often normal"
    else
        bashio::log.error "  ❌ Proxy connection tests failed"
        bashio::log.error "     Check V2Ray addon configuration and subscription"
    fi
fi

# 创建系统级代理设置指南
bashio::log.info "🔧 Creating system proxy configuration guide..."

# 确保目录存在
mkdir -p /data/system_proxy

cat > /data/system_proxy/setup.sh << EOF
#!/bin/bash
# Home Assistant System Proxy Setup Script
# Run this script on the Home Assistant host to enable system-wide proxy

echo "Setting up system-wide proxy for Home Assistant..."

# Configure environment variables
cat >> /etc/profile << 'ENVEOF'
# Home Assistant System Proxy Configuration
export http_proxy="${PROXY_HTTP}"
export https_proxy="${PROXY_HTTP}"
export no_proxy="${NO_PROXY}"
ENVEOF

# Configure systemd services
mkdir -p /etc/systemd/system.conf.d/
cat > /etc/systemd/system.conf.d/proxy.conf << 'SYSEOF'
[Manager]
DefaultEnvironment="http_proxy=${PROXY_HTTP}"
DefaultEnvironment="https_proxy=${PROXY_HTTP}"
DefaultEnvironment="no_proxy=${NO_PROXY}"
SYSEOF

# Reload systemd and restart supervisor
systemctl daemon-reload
systemctl restart hassio-supervisor

echo "System proxy configuration completed!"
echo "Proxy: ${PROXY_HTTP}"
echo "SOCKS5: ${PROXY_SOCKS}" 
echo "No Proxy: ${NO_PROXY}"
EOF

chmod +x /data/system_proxy/setup.sh

# 创建使用说明
cat > /data/system_proxy/README.md << EOF
# Home Assistant System Proxy Configuration

## Current Proxy Settings

- **SOCKS5 Proxy**: ${PROXY_SOCKS} ✅
- **HTTP Proxy**: ${PROXY_HTTP} $([ "${HTTP_IP}" != "Failed" ] && echo "✅" || echo "⚠️")
- **Exclude**: ${NO_PROXY}

## Usage Examples

### Command Line Tools
\`\`\`bash
# Using SOCKS5 (recommended)
curl --socks5 ${PROXY_SOCKS} https://httpbin.org/ip

# Using HTTP proxy
curl --proxy ${PROXY_HTTP} https://httpbin.org/ip
\`\`\`

### Home Assistant Integrations
Some integrations support proxy configuration:
\`\`\`yaml
# In configuration.yaml (if supported by integration)
some_integration:
  proxy: "${PROXY_SOCKS}"
\`\`\`

### Node-RED
\`\`\`javascript
// In HTTP Request node
msg.proxy = "${PROXY_HTTP}";
\`\`\`

### Python Scripts
\`\`\`python
import requests

proxies = {
    'http': '${PROXY_HTTP}',
    'https': '${PROXY_HTTP}'
}

response = requests.get('https://httpbin.org/ip', proxies=proxies)
\`\`\`

## System-Wide Setup (Advanced)

To enable system-wide proxy for all Home Assistant components:

1. SSH to your Home Assistant host
2. Run: \`docker exec addon_$(bashio::addon.slug) cat /data/system_proxy/setup.sh | bash\`

**Warning**: This affects the entire system. Test carefully.

## Status

- Proxy Service: Running
- SOCKS5 Test: $([ "${SOCKS_IP}" != "Failed" ] && echo "✅ Working (${SOCKS_IP})" || echo "❌ Failed")
- HTTP Test: $([ "${HTTP_IP}" != "Failed" ] && echo "✅ Working (${HTTP_IP})" || echo "⚠️ Not working (often normal)")

Generated: $(date)
EOF

bashio::log.info "📄 Configuration files created in /data/system_proxy/"
bashio::log.info "   - setup.sh: System-wide proxy setup script"
bashio::log.info "   - README.md: Usage examples and documentation"
bashio::log.warning ""
bashio::log.warning "🔧 To enable system-wide proxy (optional):"
bashio::log.warning "   1. SSH to your Home Assistant host"
bashio::log.warning "   2. Run: /usr/share/hassio/share/system_proxy_setup.sh"
bashio::log.warning "   3. This will configure system-level proxy settings"
bashio::log.warning ""

# 创建健康检查函数
check_proxy_health() {
    if timeout 5 curl -s --socks5 "${V2RAY_AVAILABLE}:${SOCKS_PORT}" https://www.google.com > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

bashio::log.info "✅ System proxy configuration completed"
bashio::log.info ""
bashio::log.info "🎯 Proxy endpoints available:"
bashio::log.info "   SOCKS5: ${PROXY_SOCKS}"
bashio::log.info "   HTTP:   ${PROXY_HTTP}"
bashio::log.info ""
bashio::log.info "🧪 Test commands:"
bashio::log.info "   curl --proxy ${PROXY_SOCKS} https://httpbin.org/ip"
bashio::log.info "   curl --proxy ${PROXY_HTTP} https://httpbin.org/ip"

# 主监控循环
bashio::log.info "🔄 Starting monitoring loop..."
HEALTH_CHECK_INTERVAL=300  # 5分钟
LAST_STATUS="unknown"

while true; do
    sleep ${HEALTH_CHECK_INTERVAL}
    
    if check_proxy_health; then
        if [ "${LAST_STATUS}" != "healthy" ]; then
            bashio::log.info "💚 Proxy is healthy"
            LAST_STATUS="healthy"
        fi
    else
        if [ "${LAST_STATUS}" != "unhealthy" ]; then
            bashio::log.warning "🚨 Proxy health check failed"
            bashio::log.warning "   V2Ray addon may be down or subscription expired"
            LAST_STATUS="unhealthy"
        fi
    fi
done