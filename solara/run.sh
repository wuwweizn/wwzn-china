#!/bin/bash
# 简化版启动脚本 - 不依赖 bashio::config

set -e

echo "[INFO] Starting Solara Music Player..."

# 尝试从环境变量或使用默认值
API_URL="${API_URL:-https://music-api.gdstudio.xyz}"
LOG_LEVEL="${LOG_LEVEL:-info}"

# 如果有配置文件，尝试读取
if [ -f "/data/options.json" ]; then
    if command -v jq >/dev/null 2>&1; then
        API_URL=$(jq -r '.api_url // "https://music-api.gdstudio.xyz"' /data/options.json 2>/dev/null || echo "https://music-api.gdstudio.xyz")
        LOG_LEVEL=$(jq -r '.log_level // "info"' /data/options.json 2>/dev/null || echo "info")
    fi
fi

echo "[INFO] API URL: ${API_URL}"
echo "[INFO] Log Level: ${LOG_LEVEL}"

# 确保数据目录存在
mkdir -p /config/solara /share/solara

# 检查默认安装
if [ ! -f "/var/www/html/index.html" ]; then
    echo "[ERROR] index.html not found!"
    exit 1
fi

echo "[INFO] Configuring API URL..."

# 查找并替换 baseUrl
if grep -q "baseUrl" /var/www/html/index.html; then
    echo "[INFO] Found baseUrl configuration"
    
    # 备份
    cp /var/www/html/index.html /var/www/html/index.html.bak
    
    # 替换所有可能的格式
    sed -i "s|baseUrl[[:space:]]*:[[:space:]]*['\"]https\?://[^'\"]*['\"]|baseUrl: '${API_URL}'|g" /var/www/html/index.html
    sed -i "s|baseUrl:['\"]https\?://[^'\"]*['\"]|baseUrl:'${API_URL}'|g" /var/www/html/index.html
    
    # 验证
    if grep -q "${API_URL}" /var/www/html/index.html; then
        echo "[INFO] ✓ API URL configured successfully!"
        grep "baseUrl" /var/www/html/index.html | head -1
    else
        echo "[WARNING] API URL may not have been updated"
    fi
else
    echo "[ERROR] Cannot find 'baseUrl' in index.html"
    exit 1
fi

# 备份到配置目录
if [ ! -f "/config/solara/index.html" ]; then
    echo "[INFO] Creating backup in /config/solara"
    cp -r /var/www/html/* /config/solara/ 2>/dev/null || true
fi

# 测试 nginx
echo "[INFO] Testing nginx configuration..."
nginx -t

# 启动 nginx
echo "[INFO] Starting Nginx on port 3100"
exec nginx -g "daemon off;"