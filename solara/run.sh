#!/usr/bin/env bashio

set -e

bashio::log.info "Starting Solara Music Player..."

# 获取配置
API_URL=$(bashio::config 'api_url')
LOG_LEVEL=$(bashio::config 'log_level')

bashio::log.info "API URL: ${API_URL}"
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
    # 如果配置目录为空，将默认文件复制到配置目录作为备份
    if [ -d "/config/solara" ] && [ -z "$(ls -A /config/solara 2>/dev/null)" ]; then
        bashio::log.info "Backing up default files to /config/solara"
        cp -r /var/www/html/* /config/solara/ 2>/dev/null || true
    fi
fi

# 更新 API URL
bashio::log.info "Configuring API URL..."
if [ -f "/var/www/html/index.html" ]; then
    # 显示替换前的内容（调试用）
    bashio::log.debug "Original API config:"
    grep -n "baseUrl" /var/www/html/index.html | head -5 || true
    
    # 尝试多种替换模式
    # 模式 1: baseUrl: 'xxx' 或 baseUrl: "xxx"
    sed -i "s|baseUrl:[[:space:]]*['\"][^'\"]*['\"]|baseUrl: '${API_URL}'|g" /var/www/html/index.html
    
    # 模式 2: baseUrl:'xxx' 或 baseUrl:"xxx" (无空格)
    sed -i "s|baseUrl:['\"][^'\"]*['\"]|baseUrl:'${API_URL}'|g" /var/www/html/index.html
    
    # 显示替换后的内容（调试用）
    bashio::log.info "Updated API config:"
    grep -n "baseUrl" /var/www/html/index.html | head -5 || true
    
    # 验证是否替换成功
    if grep -q "${API_URL}" /var/www/html/index.html; then
        bashio::log.info "✓ API URL configured successfully"
    else
        bashio::log.warning "⚠ API URL replacement may have failed"
        bashio::log.warning "Please check /var/www/html/index.html manually"
    fi
else
    bashio::log.error "index.html not found!"
    exit 1
fi

# 检查 nginx 配置
bashio::log.info "Testing nginx configuration..."
nginx -t

# 启动 nginx
bashio::log.info "Starting Nginx on port 3100"
exec nginx -g "daemon off;"