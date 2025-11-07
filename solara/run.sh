#!/usr/bin/env bashio

set -e

bashio::log.info "Starting Solara Music Player..."

# 获取配置
API_MODE=$(bashio::config 'api_mode' 'local')
EXTERNAL_API_URL=$(bashio::config 'external_api_url' '')
LOG_LEVEL=$(bashio::config 'log_level')

bashio::log.info "API Mode: ${API_MODE}"
bashio::log.info "Log Level: ${LOG_LEVEL}"

# 确保数据目录存在
mkdir -p /config/solara /share/solara

# 检查是否使用自定义配置
if [ -d "/config/solara" ] && [ -n "$(ls -A /config/solara 2>/dev/null)" ]; then
    bashio::log.info "Using custom configuration from /config/solara"
    rm -rf /var/www/html/*
    cp -r /config/solara/* /var/www/html/
else
    bashio::log.info "Using default Solara files"
    if [ -d "/config/solara" ] && [ -z "$(ls -A /config/solara 2>/dev/null)" ]; then
        bashio::log.info "Backing up default files to /config/solara"
        cp -r /var/www/html/* /config/solara/ 2>/dev/null || true
    fi
fi

# 配置 API URL
if [ -f "/var/www/html/index.html" ]; then
    bashio::log.info "Configuring API..."
    
    if [ "${API_MODE}" = "local" ]; then
        # 使用本地 API 代理
        API_URL="http://$(hostname -i | awk '{print $1}'):3100"
        bashio::log.info "Using local API proxy"
        bashio::log.info "API URL: ${API_URL}/api"
    elif [ "${API_MODE}" = "external" ] && [ -n "${EXTERNAL_API_URL}" ]; then
        # 使用外部 API
        API_URL="${EXTERNAL_API_URL}"
        bashio::log.info "Using external API: ${API_URL}"
    else
        # 默认使用 GD 音乐台
        API_URL="https://music-api.gdstudio.xyz"
        bashio::log.info "Using default GD Studio API"
    fi
    
    # 替换 API URL
    sed -i "s|baseUrl:[[:space:]]*['\"][^'\"]*['\"]|baseUrl: '${API_URL}'|g" /var/www/html/index.html
    sed -i "s|baseUrl:['\"][^'\"]*['\"]|baseUrl:'${API_URL}'|g" /var/www/html/index.html
    
    # 验证
    if grep -q "${API_URL}" /var/www/html/index.html; then
        bashio::log.info "✓ API configured successfully"
    else
        bashio::log.warning "⚠ API configuration may have failed"
    fi
else
    bashio::log.error "index.html not found!"
    exit 1
fi

# 检查 nginx 配置
bashio::log.info "Testing nginx configuration..."
nginx -t

# 启动所有服务（通过 supervisord）
bashio::log.info "Starting services..."
exec /usr/bin/supervisord -c /etc/supervisord.conf