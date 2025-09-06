#!/bin/bash
# ha-system-proxy/run.sh
set -e

# 读取配置
PROXY_MODE=$(jq -r '.proxy_mode' /data/options.json)
SOCKS_PORT=$(jq -r '.v2ray_socks_port' /data/options.json)  
HTTP_PORT=$(jq -r '.v2ray_http_port' /data/options.json)
ENABLE_SUPERVISOR=$(jq -r '.enable_for_supervisor' /data/options.json)
ENABLE_ADDONS=$(jq -r '.enable_for_addons' /data/options.json)
BYPASS_PRIVATE=$(jq -r '.bypass_private_networks' /data/options.json)
BYPASS_CHINA=$(jq -r '.bypass_china_sites' /data/options.json)
TEST_CONNECTIVITY=$(jq -r '.test_connectivity' /data/options.json)

echo "🚀 Starting HA System Proxy..."
echo "📋 Proxy mode: $PROXY_MODE"
echo "🌐 SOCKS5 port: $SOCKS_PORT"
echo "🌐 HTTP port: $HTTP_PORT"

# 等待 V2Ray 加载项启动
echo "⏳ Waiting for V2Ray addon to start..."
for i in {1..30}; do
    if curl -s --connect-timeout 2 --socks5 127.0.0.1:$SOCKS_PORT https://www.google.com > /dev/null 2>&1; then
        echo "✅ V2Ray addon is ready"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ V2Ray addon not ready after 30 attempts"
        exit 1
    fi
    sleep 2
done

if [ "$PROXY_MODE" = "disabled" ]; then
    echo "🔄 Proxy mode disabled, cleaning up..."
    # 清理代理配置
    > /etc/profile.d/proxy.sh
    systemctl restart hassio-supervisor 2>/dev/null || true
    echo "✅ Proxy disabled"
    exec tail -f /dev/null
fi

# 构建代理配置
PROXY_HTTP="http://127.0.0.1:$HTTP_PORT"
PROXY_SOCKS="socks5://127.0.0.1:$SOCKS_PORT"

# 构建 no_proxy 列表
NO_PROXY="localhost,127.0.0.1,::1"
if [ "$BYPASS_PRIVATE" = "true" ]; then
    NO_PROXY="$NO_PROXY,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,fd00::/8"
fi

echo "🔧 Configuring system proxy..."

# 创建系统环境配置
cat > /etc/profile.d/proxy.sh << EOF
# System Proxy Configuration - Managed by HA System Proxy Addon
export http_proxy="$PROXY_HTTP"
export https_proxy="$PROXY_HTTP"
export ftp_proxy="$PROXY_HTTP"
export HTTP_PROXY="$PROXY_HTTP"
export HTTPS_PROXY="$PROXY_HTTP"
export FTP_PROXY="$PROXY_HTTP"
export no_proxy="$NO_PROXY"
export NO_PROXY="$NO_PROXY"
EOF

# 使配置立即生效
source /etc/profile.d/proxy.sh

# 配置 systemd 服务的代理
if [ "$ENABLE_SUPERVISOR" = "true" ]; then
    echo "🔧 Configuring Supervisor proxy..."
    mkdir -p /etc/systemd/system/hassio-supervisor.service.d/
    cat > /etc/systemd/system/hassio-supervisor.service.d/proxy.conf << EOF
[Service]
Environment="http_proxy=$PROXY_HTTP"
Environment="https_proxy=$PROXY_HTTP"
Environment="no_proxy=$NO_PROXY"
EOF
    systemctl daemon-reload
fi

# 配置 Docker 守护进程代理（影响所有加载项）
if [ "$ENABLE_ADDONS" = "true" ]; then
    echo "🔧 Configuring Docker daemon proxy..."
    mkdir -p /etc/systemd/system/docker.service.d/
    cat > /etc/systemd/system/docker.service.d/proxy.conf << EOF
[Service]
Environment="HTTP_PROXY=$PROXY_HTTP"
Environment="HTTPS_PROXY=$PROXY_HTTP"
Environment="NO_PROXY=$NO_PROXY"
EOF
    systemctl daemon-reload
    systemctl restart docker 2>/dev/null || true
fi

# 配置 DNS 解析（可选）
if [ "$BYPASS_CHINA" = "false" ]; then
    echo "🔧 Configuring DNS resolution..."
    # 可以配置 DNS over HTTPS 或其他 DNS 解析方案
fi

# 测试代理连通性
if [ "$TEST_CONNECTIVITY" = "true" ]; then
    echo "🧪 Testing proxy connectivity..."
    
    # 测试直连
    echo "  📡 Testing direct connection..."
    DIRECT_IP=$(curl -s --connect-timeout 5 https://httpbin.org/ip | jq -r '.origin' 2>/dev/null || echo "Failed")
    echo "  📍 Direct IP: $DIRECT_IP"
    
    # 测试代理
    echo "  🔄 Testing proxy connection..."
    PROXY_IP=$(curl -s --connect-timeout 5 --proxy $PROXY_SOCKS https://httpbin.org/ip | jq -r '.origin' 2>/dev/null || echo "Failed")
    echo "  🌍 Proxy IP: $PROXY_IP"
    
    if [ "$DIRECT_IP" != "$PROXY_IP" ] && [ "$PROXY_IP" != "Failed" ]; then
        echo "  ✅ Proxy working correctly"
    else
        echo "  ⚠️  Proxy may not be working properly"
    fi
fi

# 创建健康检查脚本
cat > /usr/local/bin/proxy-health-check << 'EOF'
#!/bin/bash
# 检查 V2Ray 是否可用
if ! curl -s --connect-timeout 3 --socks5 127.0.0.1:10808 https://www.google.com > /dev/null 2>&1; then
    echo "V2Ray proxy not available"
    exit 1
fi
echo "V2Ray proxy is healthy"
EOF
chmod +x /usr/local/bin/proxy-health-check

# 定期健康检查
(
    while true; do
        sleep 300  # 5分钟检查一次
        if ! /usr/local/bin/proxy-health-check > /dev/null 2>&1; then
            echo "🚨 Proxy health check failed, attempting to recover..."
            # 可以添加恢复逻辑
        fi
    done
) &

echo "✅ System proxy configuration completed"
echo ""
echo "📊 Configuration Summary:"
echo "  🔹 Proxy Mode: $PROXY_MODE"
echo "  🔹 HTTP Proxy: $PROXY_HTTP"
echo "  🔹 SOCKS5 Proxy: $PROXY_SOCKS"
echo "  🔹 No Proxy: $NO_PROXY"
echo "  🔹 Supervisor Proxy: $ENABLE_SUPERVISOR"
echo "  🔹 Docker/Addons Proxy: $ENABLE_ADDONS"
echo ""
echo "🎯 To test the configuration:"
echo "  curl --proxy $PROXY_SOCKS https://httpbin.org/ip"

# 监控模式 - 保持容器运行并提供状态监控
while true; do
    sleep 60
    # 可以在这里添加状态监控逻辑
done