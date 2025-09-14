#!/bin/bash
set -e

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] ✅${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] ⚠️${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ❌${NC} $1"
}

# 显示启动横幅
cat << 'EOF'

    ╔═══════════════════════════════════════════╗
    ║        🎵 Alger Music Player Add-on        ║
    ║                                           ║
    ║     With UnblockNeteaseMusic Support      ║
    ╚═══════════════════════════════════════════╝

EOF

log "Initializing Alger Music Player Home Assistant Add-on..."

# 读取 Home Assistant Add-on 选项（如果可用）
if command -v bashio &> /dev/null; then
    log "Loading Home Assistant Add-on configuration..."
    
    # 从 options.json 读取配置
    MUSIC_API_URL=$(bashio::config 'music_api_url' 'http://localhost:3001')
    LOG_LEVEL=$(bashio::config 'log_level' 'info')
    ENABLE_UNM=$(bashio::config 'enable_unm' 'true')
    UNM_SOURCE=$(bashio::config 'unm_source' 'netease qq kuwo kugou baidu migu')
    
    log "Configuration loaded:"
    log "  - Music API URL: $MUSIC_API_URL"
    log "  - Log Level: $LOG_LEVEL"  
    log "  - Enable UNM: $ENABLE_UNM"
    log "  - UNM Sources: $UNM_SOURCE"
else
    log_warning "bashio not available, using environment variables"
    
    # 使用环境变量作为回退
    MUSIC_API_URL=${MUSIC_API_URL:-"http://localhost:3001"}
    LOG_LEVEL=${LOG_LEVEL:-"info"}
    ENABLE_UNM=${ENABLE_UNM:-"true"}
    UNM_SOURCE=${UNM_SOURCE:-"netease qq kuwo kugou baidu migu"}
fi

# 导出环境变量供 supervisor 使用
export MUSIC_API_URL
export LOG_LEVEL
export ENABLE_UNM
export UNM_SOURCE

# 验证必要文件和目录
log "Verifying installation..."

if [ ! -d "/app" ]; then
    log_error "Alger Music Player application directory not found!"
    exit 1
fi

if [ ! -f "/opt/unm/app.js" ]; then
    log_error "UnblockNeteaseMusic not found!"
    exit 1
fi

if [ ! -f "/etc/nginx/nginx.conf" ]; then
    log_error "Nginx configuration not found!"
    exit 1
fi

log_success "All required files verified"

# 设置权限
log "Setting up permissions..."
chown -R app:app /app /opt/unm
chown -R nginx:nginx /var/log/nginx /run/nginx
chmod 755 /opt/unm /app

# 检查并安装 Node.js 依赖（如果需要）
if [ -f "/app/package.json" ] && [ ! -d "/app/node_modules" ]; then
    log "Installing Node.js dependencies for Alger Music Player..."
    cd /app
    npm install --production --no-audit || log_warning "Failed to install dependencies, continuing anyway"
fi

# 创建必要的日志目录
mkdir -p /var/log
touch /var/log/supervisord.log

log_success "Permissions and dependencies configured"

# 验证端口可用性
log "Checking port availability..."
if netstat -tulpn 2>/dev/null | grep -q ":3010 "; then
    log_warning "Port 3010 might be in use"
fi

# 创建健康检查端点
log "Setting up health check..."
mkdir -p /usr/share/nginx/html
cat > /usr/share/nginx/html/50x.html << 'EOF'
<!DOCTYPE html>
<html><head><title>Service Unavailable</title></head>
<body><h1>Service Unavailable</h1><p>The music service is temporarily unavailable.</p></body></html>
EOF

cat > /usr/share/nginx/html/404.html << 'EOF'
<!DOCTYPE html>
<html><head><title>Not Found</title></head>
<body><h1>Not Found</h1><p>The requested resource was not found.</p></body></html>
EOF

# 显示服务状态
log "Service configuration:"
log "  📱 Web Interface: http://localhost:3010"
log "  🎵 Music API: http://localhost:3010/api_music/"
log "  🔓 UnblockNeteaseMusic: http://localhost:3010/unm/"
log "  💚 Health Check: http://localhost:3010/health"

# 如果是调试模式，显示更多信息
if [ "$LOG_LEVEL" = "debug" ] || [ "$LOG_LEVEL" = "trace" ]; then
    log "Debug information:"
    log "  - Node.js version: $(node --version)"
    log "  - NPM version: $(npm --version)"
    log "  - Nginx version: $(nginx -v 2>&1)"
    log "  - Available memory: $(free -h | awk '/^Mem:/ {print $7}')"
    log "  - CPU cores: $(nproc)"
fi

log_success "Initialization complete!"
log "🚀 Starting services with supervisor..."

# 启动 supervisor
exec /usr/bin/supervisord -c /etc/supervisor.d/supervisord.conf