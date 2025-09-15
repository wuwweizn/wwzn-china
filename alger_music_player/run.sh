#!/bin/bash

# ==============================================================================
# Alger Music Player Add-on for Home Assistant
# ==============================================================================

# 等待配置文件
CONFIG_PATH="/data/options.json"
while [ ! -f "$CONFIG_PATH" ]; do
    echo "Waiting for configuration..."
    sleep 1
done

# 读取配置（如果bashio不可用，使用jq）
if command -v bashio &> /dev/null; then
    MUSIC_API_URL=$(bashio::config 'music_api_url' 'http://localhost:3001')
    LOG_LEVEL=$(bashio::config 'log_level' 'info')
    echo "Starting Alger Music Player..."
    echo "Music API URL: ${MUSIC_API_URL}"
    echo "Log level: ${LOG_LEVEL}"
else
    # 备用方案：直接读取JSON
    if [ -f "$CONFIG_PATH" ]; then
        MUSIC_API_URL=$(jq -r '.music_api_url // "http://localhost:3001"' "$CONFIG_PATH")
        LOG_LEVEL=$(jq -r '.log_level // "info"' "$CONFIG_PATH")
        echo "Starting Alger Music Player..."
        echo "Music API URL: ${MUSIC_API_URL}"
        echo "Log level: ${LOG_LEVEL}"
    fi
fi

# 设置环境变量
export MUSIC_API_URL="${MUSIC_API_URL:-http://localhost:3001}"

# 更新nginx配置中的API地址（如果需要）
if [ -f /etc/nginx/nginx.conf ] && [ "$MUSIC_API_URL" != "http://localhost:3001" ]; then
    # 这里可以根据需要修改nginx配置
    echo "Updating nginx configuration with custom API URL..."
fi

# 启动nginx
echo "Starting nginx on port 8080..."
exec nginx -g 'daemon off;'