#!/bin/bash

# ==============================================================================
# Home Assistant Add-on: YesPlayMusic
# YesPlayMusic 启动脚本  
# ==============================================================================

echo "正在启动 YesPlayMusic..."

# 检查 bashio 是否可用并设置 API 地址
api_url="http://localhost:3000"
if command -v bashio &> /dev/null; then
    echo "bashio 可用，检查配置..."
    # 检查是否配置了自定义 API URL
    if bashio::config.exists 'netease_api_url'; then
        custom_api=$(bashio::config 'netease_api_url')
        if [ ! -z "$custom_api" ]; then
            api_url="$custom_api"
            echo "使用自定义网易云API地址: $api_url"
        else
            echo "使用内置API服务"
        fi
    else
        echo "使用内置API服务"
    fi
else
    echo "bashio 不可用，使用内置API服务"
fi

# 启动 API 服务（如果使用内置API）
if [ "$api_url" = "http://localhost:3000" ]; then
    echo "启动内置网易云音乐API服务..."
    cd /api
    node app.js &
    API_PID=$!
    echo "API 服务已启动，PID: $API_PID"
    
    # 等待API服务启动
    echo "等待API服务启动..."
    sleep 5
fi

echo "YesPlayMusic 正在启动，Web界面将在端口80上提供服务"

# 启动 nginx
exec nginx -g "daemon off;"