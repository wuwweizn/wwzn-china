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

# 更新 API URL - 使用多种匹配模式
bashio::log.info "Configuring API URL..."
if [ -f "/var/www/html/index.html" ]; then
    
    # 备份原文件
    cp /var/www/html/index.html /var/www/html/index.html.bak
    
    bashio::log.info "Searching for API configuration..."
    
    # 查找并显示当前的 baseUrl 配置
    if grep -q "baseUrl" /var/www/html/index.html; then
        bashio::log.info "Found baseUrl configuration:"
        grep -n "baseUrl" /var/www/html/index.html | head -3
        
        # 尝试多种替换模式
        # 模式 1: baseUrl: 'xxx' 或 baseUrl: "xxx" (有空格)
        sed -i "s|baseUrl[[:space:]]*:[[:space:]]*['\"][^'\"]*['\"]|baseUrl: '${API_URL}'|g" /var/www/html/index.html
        
        # 模式 2: baseUrl:'xxx' 或 baseUrl:"xxx" (无空格)
        sed -i "s|baseUrl:['\"][^'\"]*['\"]|baseUrl:'${API_URL}'|g" /var/www/html/index.html
        
        # 模式 3: baseUrl = 'xxx' 或 baseUrl = "xxx" (赋值形式)
        sed -i "s|baseUrl[[:space:]]*=[[:space:]]*['\"][^'\"]*['\"]|baseUrl = '${API_URL}'|g" /var/www/html/index.html
        
        bashio::log.info "Replacement completed, checking result..."
        
        # 验证替换结果
        if grep -q "${API_URL}" /var/www/html/index.html; then
            bashio::log.info "✓ API URL configured successfully!"
            bashio::log.info "New configuration:"
            grep -n "${API_URL}" /var/www/html/index.html | head -3
        else
            bashio::log.warning "⚠ Warning: API URL may not have been replaced"
            bashio::log.warning "Trying alternative method..."
            
            # 使用 Python 进行更精确的替换
            python3 << EOF
import re
with open('/var/www/html/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# 多种正则模式
patterns = [
    (r'baseUrl\s*:\s*["\'][^"\']*["\']', f'baseUrl: "{API_URL}"'),
    (r'baseUrl\s*=\s*["\'][^"\']*["\']', f'baseUrl = "{API_URL}"'),
    (r"baseUrl\s*:\s*'[^']*'", f"baseUrl: '{API_URL}'"),
    (r'baseUrl\s*:\s*"[^"]*"', f'baseUrl: "{API_URL}"'),
]

for pattern, replacement in patterns:
    content = re.sub(pattern, replacement, content)

with open('/var/www/html/index.html', 'w', encoding='utf-8') as f:
    f.write(content)
    
print("Python replacement completed")
EOF
            
            # 再次验证
            if grep -q "${API_URL}" /var/www/html/index.html; then
                bashio::log.info "✓ API URL configured successfully with Python!"
            else
                bashio::log.error "✗ Failed to configure API URL"
                bashio::log.error "Please manually edit /config/solara/index.html"
                bashio::log.error "Search for 'baseUrl' and replace with: ${API_URL}"
            fi
        fi
    else
        bashio::log.error "Cannot find 'baseUrl' in index.html"
        bashio::log.error "This may not be a valid Solara installation"
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