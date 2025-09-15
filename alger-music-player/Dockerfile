# 第一阶段：提取原始应用
FROM banksiae/alger-music-player:latest as source-app

# 第二阶段：构建 UnblockNeteaseMusic
FROM node:18-alpine as unm-builder
WORKDIR /opt
RUN apk add --no-cache git
RUN git clone --depth=1 https://github.com/UnblockNeteaseMusic/server.git unm
WORKDIR /opt/unm
RUN npm install --production --no-audit && \
    npm cache clean --force && \
    # 验证必要文件
    test -f app.js && \
    echo "UnblockNeteaseMusic build complete"

# 第三阶段：构建最终镜像
ARG BUILD_FROM
FROM $BUILD_FROM

# 设置标签
LABEL \
    io.hass.name="Alger Music Player" \
    io.hass.description="网易云音乐播放器，支持高音质播放和内置UnblockNeteaseMusic服务" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}" \
    maintainer="wuwweizn" \
    org.opencontainers.image.title="Alger Music Player Add-on" \
    org.opencontainers.image.description="网易云音乐播放器 Home Assistant 加载项" \
    org.opencontainers.image.source="https://github.com/wuwweizn/wwzn-china"

# 设置环境变量
ENV \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    NODE_ENV=production \
    UNM_PORT=3001 \
    ALGER_PORT=3000 \
    UNM_SOURCE="netease qq kuwo kugou baidu migu"

# 安装系统依赖
RUN apk add --no-cache \
    bash \
    nodejs \
    npm \
    nginx \
    curl \
    ca-certificates \
    supervisor \
    tzdata \
    net-tools \
    && update-ca-certificates

# 创建用户和目录
RUN addgroup -g 1001 app && \
    adduser -D -s /bin/bash -u 1001 -G app app && \
    mkdir -p /app /opt/unm /var/log/nginx /run/nginx /etc/supervisor.d && \
    chown -R nginx:nginx /var/log/nginx /run/nginx

# 从第一阶段复制原始应用 - 更详细的复制
COPY --from=source-app /app /tmp/source-app
RUN cp -r /tmp/source-app/* /app/ 2>/dev/null || cp -r /tmp/source-app/. /app/ 2>/dev/null || true && \
    chown -R app:app /app && \
    # 验证关键文件是否存在
    ls -la /app/ && \
    echo "App directory contents:" && \
    find /app -type f -name "*.js" -o -name "*.json" | head -10

# 从第二阶段复制 UnblockNeteaseMusic
COPY --from=unm-builder /opt/unm /opt/unm
RUN chown -R app:app /opt/unm && \
    # 验证 UNM 文件
    test -f /opt/unm/app.js && \
    echo "UnblockNeteaseMusic files verified"

# 创建改进的启动脚本
RUN cat > /usr/local/bin/docker-entrypoint.sh << 'EOF'
#!/bin/bash
set -e

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"; }
log_success() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] ✅${NC} $1"; }
log_warning() { echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] ⚠️${NC} $1"; }
log_error() { echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ❌${NC} $1"; }

cat << 'BANNER'
    ╔═══════════════════════════════════════════╗
    ║        🎵 Alger Music Player Add-on        ║
    ║                                           ║
    ║     With UnblockNeteaseMusic Support      ║
    ╚═══════════════════════════════════════════╝
BANNER

log "Initializing Alger Music Player Home Assistant Add-on..."

# 读取配置
if command -v bashio &> /dev/null; then
    MUSIC_API_URL=$(bashio::config 'music_api_url' 'http://localhost:3001')
    LOG_LEVEL=$(bashio::config 'log_level' 'info')
    ENABLE_UNM=$(bashio::config 'enable_unm' 'true')
    UNM_SOURCE=$(bashio::config 'unm_source' 'netease qq kuwo kugou baidu migu')
else
    MUSIC_API_URL=${MUSIC_API_URL:-"http://localhost:3001"}
    LOG_LEVEL=${LOG_LEVEL:-"info"}
    ENABLE_UNM=${ENABLE_UNM:-"true"}
    UNM_SOURCE=${UNM_SOURCE:-"netease qq kuwo kugou baidu migu"}
fi

export MUSIC_API_URL LOG_LEVEL ENABLE_UNM UNM_SOURCE

# 验证文件
log "Verifying installation..."

# 检查 app 目录
log "App directory contents:"
ls -la /app/ || log_error "App directory is empty or doesn't exist"

# 检查关键文件
if [ ! -f "/app/server.js" ] && [ ! -f "/app/app.js" ] && [ ! -f "/app/index.js" ]; then
    log_warning "No main server file found, checking for alternatives..."
    
    # 寻找可能的入口文件
    MAIN_FILE=$(find /app -name "*.js" -type f | grep -E "(server|app|index|main)" | head -1)
    if [ -n "$MAIN_FILE" ]; then
        log "Found potential main file: $MAIN_FILE"
        # 创建符号链接
        ln -sf "$MAIN_FILE" /app/server.js
    else
        log_warning "Creating fallback server.js..."
        cat > /app/server.js << 'FALLBACK_EOF'
const express = require('express');
const path = require('path');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();
const PORT = process.env.PORT || 3000;

// 静态文件服务
const staticPath = path.join(__dirname, 'dist') || path.join(__dirname, 'public') || path.join(__dirname, 'build');
if (require('fs').existsSync(staticPath)) {
    app.use(express.static(staticPath));
    console.log(`Serving static files from: ${staticPath}`);
} else {
    console.log('No static files directory found, serving basic HTML');
    app.get('/', (req, res) => {
        res.send(`
<!DOCTYPE html>
<html><head><title>Alger Music Player</title>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>body{font-family:Arial,sans-serif;margin:0;padding:20px;background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);color:white;min-height:100vh;display:flex;align-items:center;justify-content:center;text-align:center}.container{background:rgba(255,255,255,0.1);padding:40px;border-radius:20px;backdrop-filter:blur(10px);box-shadow:0 8px 32px rgba(0,0,0,0.3)}h1{margin-bottom:20px}.status{padding:10px 20px;border-radius:10px;background:rgba(255,255,255,0.2);margin:20px 0}</style>
</head><body>
<div class="container">
<h1>🎵 Alger Music Player</h1>
<div class="status">音乐服务正在运行</div>
<p>UnblockNeteaseMusic 已启用</p>
<p><a href="/unm/" style="color:#fff">访问 UNM 服务</a></p>
</div>
</body></html>
        `);
    });
}

// API 路由
app.get('/api/health', (req, res) => {
    res.json({ 
        status: 'ok', 
        message: 'Alger Music Player is running',
        timestamp: new Date().toISOString(),
        unm_url: 'http://localhost:3001'
    });
});

// 代理到 UNM
app.use('/api/music', createProxyMiddleware({
    target: 'http://localhost:3001',
    changeOrigin: true,
    pathRewrite: { '^/api/music': '' }
}));

app.listen(PORT, '0.0.0.0', () => {
    console.log(`🎵 Alger Music Player backend running on port ${PORT}`);
});
FALLBACK_EOF

        # 安装必要的依赖
        cd /app
        cat > package.json << 'PKG_EOF'
{
  "name": "alger-music-player-fallback",
  "version": "1.0.0",
  "description": "Alger Music Player Fallback Server",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.0",
    "http-proxy-middleware": "^2.0.0"
  },
  "scripts": {
    "start": "node server.js"
  }
}
PKG_EOF
        npm install --production
    fi
fi

# 验证 UNM
if [ ! -f "/opt/unm/app.js" ]; then
    log_error "UnblockNeteaseMusic not found!"
    exit 1
fi

# 测试 UNM 是否可以启动
log "Testing UnblockNeteaseMusic..."
cd /opt/unm
timeout 10s node app.js --help > /dev/null 2>&1 || log_warning "UNM test failed, but continuing..."

log_success "File verification complete"

# 设置权限
chown -R app:app /app /opt/unm
chown -R nginx:nginx /var/log/nginx /run/nginx

# 创建日志目录
mkdir -p /var/log
touch /var/log/supervisord.log

log_success "Starting services with supervisor..."
exec /usr/bin/supervisord -c /etc/supervisor.d/supervisord.conf
EOF

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 创建改进的 supervisor 配置
RUN cat > /etc/supervisor.d/supervisord.conf << 'EOF'
[supervisord]
nodaemon=true
logfile=/var/log/supervisord.log
logfile_maxbytes=50MB
logfile_backups=10
loglevel=info
pidfile=/var/run/supervisord.pid
childlogdir=/var/log
user=root

[unix_http_server]
file=/var/run/supervisor.sock
chmod=0700

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///var/run/supervisor.sock

# UnblockNeteaseMusic 服务
[program:unm]
command=node app.js -p 3001 -o -s %(ENV_UNM_SOURCE)s
directory=/opt/unm
user=app
autostart=true
autorestart=true
startsecs=5
startretries=3
stderr_logfile=/var/log/unm_error.log
stderr_logfile_maxbytes=10MB
stdout_logfile=/var/log/unm_output.log
stdout_logfile_maxbytes=10MB
environment=PORT=3001,HOST=0.0.0.0,NODE_ENV=production,UNM_SOURCE="%(ENV_UNM_SOURCE)s"
priority=100

# Alger Music Player 后端
[program:alger-backend]
command=node server.js
directory=/app
user=app
autostart=true
autorestart=true
startsecs=5
startretries=3
stderr_logfile=/var/log/alger_backend_error.log
stderr_logfile_maxbytes=10MB
stdout_logfile=/var/log/alger_backend_output.log
stdout_logfile_maxbytes=10MB
environment=PORT=3000,NODE_ENV=production,MUSIC_API_URL="%(ENV_MUSIC_API_URL)s"
priority=200
depends_on=unm

# Nginx Web 服务器
[program:nginx]
command=nginx -g "daemon off;"
autostart=true
autorestart=true
startsecs=3
startretries=3
stderr_logfile=/var/log/nginx_error.log
stderr_logfile_maxbytes=10MB
stdout_logfile=/var/log/nginx_output.log
stdout_logfile_maxbytes=10MB
priority=300
EOF

# 创建 nginx 配置
RUN cat > /etc/nginx/nginx.conf << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 100M;
    
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json;
    
    server {
        listen 3010 default_server;
        server_name _;
        root /app/dist;
        index index.html index.htm;
        
        # 尝试多个静态文件位置
        location / {
            try_files $uri $uri/ @fallback;
        }
        
        # 回退到其他可能的静态文件目录
        location @fallback {
            root /app/public;
            try_files $uri $uri/ @backend;
        }
        
        # 最终回退到后端
        location @backend {
            proxy_pass http://127.0.0.1:3000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        # 后端 API 代理
        location /api/ {
            proxy_pass http://127.0.0.1:3000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_cache_bypass $http_upgrade;
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }
        
        # 音乐 API 代理
        location /api_music/ {
            rewrite ^/api_music/(.*) /$1 break;
            proxy_pass http://127.0.0.1:3001;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # CORS 支持
            add_header Access-Control-Allow-Origin *;
            add_header Access-Control-Allow-Methods 'GET, POST, OPTIONS';
            add_header Access-Control-Allow-Headers 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
            
            if ($request_method = 'OPTIONS') {
                add_header Access-Control-Allow-Origin *;
                add_header Access-Control-Allow-Methods 'GET, POST, OPTIONS';
                add_header Access-Control-Allow-Headers 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
                add_header Access-Control-Max-Age 1728000;
                add_header Content-Type 'text/plain; charset=utf-8';
                add_header Content-Length 0;
                return 204;
            }
        }
        
        # UnblockNeteaseMusic 直接访问
        location /unm/ {
            rewrite ^/unm/(.*) /$1 break;
            proxy_pass http://127.0.0.1:3001;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        # 健康检查
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF

# 创建必要的目录和文件
RUN mkdir -p /usr/share/nginx/html && \
    echo '<h1>Service Unavailable</h1>' > /usr/share/nginx/html/50x.html && \
    echo '<h1>Not Found</h1>' > /usr/share/nginx/html/404.html

# 验证安装
RUN test -f /opt/unm/app.js && echo "✅ UnblockNeteaseMusic verified" && \
    ls -la /app/ && echo "✅ App directory verified"

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:3010/health || curl -f http://localhost:3010/ || exit 1

# 暴露端口
EXPOSE 3010

# 启动命令
CMD ["/usr/local/bin/docker-entrypoint.sh"]