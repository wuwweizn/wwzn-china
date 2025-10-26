#!/usr/bin/env bashio

set -e

bashio::log.info "Starting Solara Music Player..."

# 获取配置
API_URL=$(bashio::config 'api_url')
LOG_LEVEL=$(bashio::config 'log_level')

bashio::log.info "API URL: ${API_URL}"
bashio::log.info "Log Level: ${LOG_LEVEL}"

# 从 API_URL 提取域名和协议
# 例如: https://music-api.gdstudio.xyz/api.php -> music-api.gdstudio.xyz
API_HOST=$(echo "$API_URL" | sed -E 's|^https?://([^/]+).*|\1|')
API_SCHEME=$(echo "$API_URL" | sed -E 's|^(https?)://.*|\1|')

bashio::log.info "API Host: ${API_HOST}"
bashio::log.info "API Scheme: ${API_SCHEME}"

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

# 更新 nginx 配置中的 API 地址
bashio::log.info "Configuring nginx reverse proxy..."
sed -i "s|server .*:443;|server ${API_HOST}:443;|g" /etc/nginx/nginx.conf
sed -i "s|proxy_set_header Host .*|proxy_set_header Host ${API_HOST};|g" /etc/nginx/nginx.conf
sed -i "s|proxy_pass https://.*|proxy_pass ${API_SCHEME}://music_api;|g" /etc/nginx/nginx.conf

bashio::log.info "✓ Nginx proxy configured to: ${API_SCHEME}://${API_HOST}"

# 检查 nginx 配置
bashio::log.info "Testing nginx configuration..."
nginx -t

# 启动 nginx
bashio::log.info "Starting Nginx on port 3100"
bashio::log.info "🎵 Solara Music Player is ready!"
bashio::log.info "📡 Proxy endpoint: /proxy -> ${API_URL}"

exec nginx -g "daemon off;"