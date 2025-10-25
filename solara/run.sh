#!/usr/bin/env bashio

set -e

bashio::log.info "Starting Solara Music Player..."

# 获取配置（带默认值）
API_URL=$(bashio::config 'api_url' 'https://music.gdstudio.xyz')
LOG_LEVEL=$(bashio::config 'log_level' 'info')

bashio::log.info "API URL: ${API_URL}"
bashio::log.info "Log Level: ${LOG_LEVEL}"

# 确保数据目录存在
mkdir -p /config/solara /share/solara

# 清理并使用默认文件
bashio::log.info "Preparing Solara files..."

# 总是从默认位置开始，避免使用损坏的配置文件
if [ -d "/var/www/html" ] && [ -n "$(ls -A /var/www/html 2>/dev/null)" ]; then
    bashio::log.info "Using default Solara installation"
    
    # 如果 /config/solara 为空或没有 index.html，复制默认文件
    if [ ! -f "/config/solara/index.html" ]; then
        bashio::log.info "Creating backup in /config/solara"
        rm -rf /config/solara/*
        cp -r /var/www/html/* /config/solara/ 2>/dev/null || true
    fi
else
    bashio::log.error "Default Solara files not found!"
    exit 1
fi

# 更新 API URL
bashio::log.info "Configuring API URL..."
if [ -f "/var/www/html/index.html" ]; then
    
    # 先检查文件是否包含 Solara 的标识
    if ! grep -q "Solara" /var/www/html/index.html; then
        bashio::log.warning "Warning: This may not be a Solara installation"
    fi
    
    # 查找 baseUrl
    if grep -q "baseUrl" /var/www/html/index.html; then
        bashio::log.info "Found baseUrl in index.html, updating..."
        
        # 显示原始配置
        bashio::log.info "Original configuration:"
        grep -n "baseUrl" /var/www/html/index.html | head -3 || true
        
        # 创建 Python 脚本进行精确替换
        cat > /tmp/update_api.py << 'PYEOF'
import re
import sys

api_url = sys.argv[1]
file_path = '/var/www/html/index.html'

try:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 保存原始内容用于对比
    original = content
    
    # 多种匹配模式
    patterns = [
        # baseUrl: 'xxx' 或 baseUrl: "xxx"
        (r"baseUrl\s*:\s*['\"]https?://[^'\"]+['\"]", f"baseUrl: '{api_url}'"),
        # baseUrl:'xxx' 或 baseUrl:"xxx"
        (r"baseUrl:['\"]https?://[^'\"]+['\"]", f"baseUrl:'{api_url}'"),
        # baseUrl = 'xxx'
        (r"baseUrl\s*=\s*['\"]https?://[^'\"]+['\"]", f"baseUrl = '{api_url}'"),
    ]
    
    replaced = False
    for pattern, replacement in patterns:
        if re.search(pattern, content):
            content = re.sub(pattern, replacement, content)
            replaced = True
            print(f"Matched pattern: {pattern}")
    
    if replaced and content != original:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"SUCCESS: API URL updated to {api_url}")
        sys.exit(0)
    else:
        print("ERROR: No baseUrl pattern matched")
        sys.exit(1)
        
except Exception as e:
    print(f"ERROR: {str(e)}")
    sys.exit(1)
PYEOF
        
        # 运行 Python 脚本
        if python3 /tmp/update_api.py "${API_URL}"; then
            bashio::log.info "✓ API URL configured successfully!"
            
            # 显示更新后的配置
            bashio::log.info "Updated configuration:"
            grep -n "baseUrl" /var/www/html/index.html | head -3 || true
            
            # 验证
            if grep -q "${API_URL}" /var/www/html/index.html; then
                bashio::log.info "✓ Verification passed: ${API_URL} found in index.html"
            else
                bashio::log.warning "⚠ Verification warning: ${API_URL} not found"
            fi
        else
            bashio::log.error "✗ Failed to update API URL"
            bashio::log.error "Trying sed as fallback..."
            
            # 备用方案：使用 sed
            sed -i "s|baseUrl[[:space:]]*:[[:space:]]*['\"]https\?://[^'\"]*['\"]|baseUrl: '${API_URL}'|g" /var/www/html/index.html
            
            if grep -q "${API_URL}" /var/www/html/index.html; then
                bashio::log.info "✓ API URL configured with sed"
            else
                bashio::log.error "✗ All methods failed"
                bashio::log.error "Please manually edit: /var/www/html/index.html"
            fi
        fi
        
        # 清理临时文件
        rm -f /tmp/update_api.py
        
    else
        bashio::log.error "Cannot find 'baseUrl' in index.html"
        bashio::log.error "Showing first 50 lines of index.html for debugging:"
        head -50 /var/www/html/index.html
        exit 1
    fi
else
    bashio::log.error "index.html not found at /var/www/html/index.html"
    ls -la /var/www/html/ || true
    exit 1
fi

# 检查 nginx 配置
bashio::log.info "Testing nginx configuration..."
nginx -t

# 启动 nginx
bashio::log.info "Starting Nginx on port 3100"
bashio::log.info "Access Solara at: http://homeassistant.local:3100"

exec nginx -g "daemon off;"