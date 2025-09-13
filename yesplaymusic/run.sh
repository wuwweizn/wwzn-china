#!/bin/bash

# ==============================================================================
# Home Assistant Add-on: YesPlayMusic
# YesPlayMusic 启动脚本  
# ==============================================================================

echo "正在启动 YesPlayMusic..."

# 检查 bashio 是否可用
if command -v bashio &> /dev/null; then
    # 检查是否配置了自定义 API URL
    if bashio::config.has_value 'netease_api_url'; then
        netease_api_url=$(bashio::config 'netease_api_url')
        echo "使用自定义网易云API地址: ${netease_api_url}"
    else
        echo "使用默认API配置"
    fi
else
    echo "bashio 不可用，使用默认配置"
fi

echo "YesPlayMusic 正在启动，Web界面将在端口80上提供服务"

# 启动 nginx（根据原镜像的启动方式）
exec nginx -g "daemon off;"