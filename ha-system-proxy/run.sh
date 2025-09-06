#!/usr/bin/with-contenv bashio
# ha-system-proxy/run.sh

# 读取配置
PROXY_MODE=$(bashio::config 'proxy_mode')
SOCKS_PORT=$(bashio::config 'v2ray_socks_port')
HTTP_PORT=$(bashio::config 'v2ray_http_port')
ENABLE_SYSTEM_PROXY=$(bashio::config 'enable_system_proxy')
BYPASS_PRIVATE=$(bashio::config 'bypass_private_networks')
TEST_CONNECTIVITY=$(bashio::config 'test_connectivity')

bashio::log.info "🚀 Starting HA System Proxy..."
bashio::log.info "📋 Proxy mode: ${PROXY_MODE}"
bashio::log.info "🌐 SOCKS5 port: ${SOCKS_PORT}"
bashio::log.info "🌐 HTTP port: ${HTTP_PORT}"

if [ "${PROXY_MODE}" = "disabled" ]; then
    bashio::log.info "🔄 Proxy mode disabled"
    exec sleep infinity
fi

# 等待 V2Ray 加载项启动
bashio::log.info "⏳ Waiting for V2Ray addon to start..."
for i in {1..30}; do
    if curl -s --connect-timeout 2 --socks5 127.0.0.1:${SOCKS_PORT} https://www.google.com > /dev/null 2>&1; then
        bashio::log.info "✅ V2Ray addon is ready"
        break
    fi
    if [ $i -eq 30 ]; then
        bashio::log.error "❌ V2Ray addon not ready after 30 attempts"
        exit 1
    fi
    sleep 2
done

# 构建代理配置
PROXY_HTTP="http://127.0.0.1:${HTTP_PORT}"
PROXY_SOCKS="socks5://127.0.0.1:${SOCKS_PORT}"

# 构建 no_proxy 列表
NO_PROXY="localhost,127.0.0.1,::1,supervisor"
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
EOF

bashio::log.info "📋 Proxy configuration:"
bashio::log.info "  🔹 HTTP Proxy: ${PROXY_HTTP}"
bashio::log.info "  🔹 SOCKS5 Proxy: ${PROXY_SOCKS}"
bashio::log.info "  🔹 No Proxy: ${NO_PROXY}"

# 测试代理连通性
if bashio::var.true "${TEST_CONNECTIVITY}"; then
    bashio::log.info "🧪 Testing proxy connectivity..."
    
    # 测试代理
    bashio::log.info "  🔄 Testing proxy connection..."
    PROXY_IP=$(curl -s --connect-timeout 5 --proxy ${PROXY_SOCKS} https://httpbin.org/ip 2>/dev/null | jq -r '.origin' 2>/dev/null || echo "Failed")
    bashio::log.info "  🌍 Proxy IP: ${PROXY_IP}"
    
    if [ "${PROXY_IP}" != "Failed" ]; then
        bashio::log.info "  ✅ Proxy working correctly"
    else
        bashio::log.warning "  ⚠️  Proxy connection test failed"
    fi
fi

# 创建系统级代理设置脚本
bashio::log.info "🔧 Creating system proxy configuration..."

# 为 Home Assistant 核心设置代理环境变量
if bashio::var.true "${ENABLE_SYSTEM_PROXY}"; then
    # 创建代理设置脚本
    cat > /tmp/set_system_proxy.sh << 'EOF'
#!/bin/bash
# 这个脚本需要在宿主机上执行
# 通过 SSH 或其他方式调用

# 设置系统环境变量
echo 'export http_proxy="http://127.0.0.1:10809"' >> /etc/profile
echo 'export https_proxy="http://127.0.0.1:10809"' >> /etc/profile
echo 'export no_proxy="localhost,127.0.0.1,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"' >> /etc/profile

# 重载配置
source /etc/profile

# 重启相关服务
systemctl restart hassio-supervisor 2>/dev/null || true
EOF

    bashio::log.info "📄 System proxy script created at /tmp/set_system_proxy.sh"
    bashio::log.warning "⚠️  To enable system-wide proxy, please run the following on your Home Assistant host:"
    bashio::log.warning "     docker exec -it addon_$(bashio::addon.slug) cat /tmp/set_system_proxy.sh | ssh root@supervisor"
fi

# 创建健康检查函数
check_proxy_health() {
    if curl -s --connect-timeout 3 --socks5 127.0.0.1:${SOCKS_PORT} https://www.google.com > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

bashio::log.info "✅ System proxy configuration completed"
bashio::log.info ""
bashio::log.info "🎯 To test the configuration manually:"
bashio::log.info "  curl --proxy ${PROXY_SOCKS} https://httpbin.org/ip"

# 主监控循环
bashio::log.info "🔄 Starting monitoring loop..."
HEALTH_CHECK_INTERVAL=300  # 5分钟

while true; do
    sleep ${HEALTH_CHECK_INTERVAL}
    
    if ! check_proxy_health; then
        bashio::log.warning "🚨 Proxy health check failed"
        # 可以添加恢复逻辑或通知
    else
        bashio::log.debug "💚 Proxy health check passed"
    fi
done