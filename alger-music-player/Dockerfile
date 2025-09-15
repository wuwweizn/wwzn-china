# 使用官方 Alger Music Player 镜像
FROM banksiae/alger-music-player:latest

# 添加标签信息
LABEL \
  io.hass.name="Alger Music Player" \
  io.hass.description="一个第三方音乐播放器，支持网易云音乐、本地服务、桌面歌词、音乐下载、远程控制" \
  io.hass.arch="aarch64|amd64|armv7" \
  io.hass.type="addon" \
  io.hass.version="1.0.6"

# 安装必要工具和进程管理器
RUN apk add --no-cache jq bash curl supervisor

# 创建supervisor配置目录
RUN mkdir -p /etc/supervisor.d /var/log/supervisor

# 创建supervisor配置文件
RUN cat > /etc/supervisor.d/supervisord.conf << 'EOF'
[supervisord]
nodaemon=true
user=root
logfile=/var/log/supervisor/supervisord.log
pidfile=/var/run/supervisord.pid

[program:netease-api]
command=node server.js
directory=/app/netease-cloud-music-api
autostart=true
autorestart=true
stdout_logfile=/var/log/supervisor/netease-api.log
stderr_logfile=/var/log/supervisor/netease-api.log
environment=PORT=3000

[program:nginx]
command=nginx -g 'daemon off;'
autostart=true
autorestart=true
stdout_logfile=/var/log/supervisor/nginx.log
stderr_logfile=/var/log/supervisor/nginx.log
EOF

# 创建Home Assistant兼容的启动脚本
RUN cat > /ha-entrypoint.sh << 'EOF'
#!/bin/bash
set -e

echo "=== Alger Music Player for Home Assistant ==="

# 读取 Home Assistant 配置
CONFIG_PATH="/data/options.json"
MUSIC_API_URL="http://localhost:3001"
LOG_LEVEL="info"

if [ -f "$CONFIG_PATH" ]; then
    echo "Reading configuration from $CONFIG_PATH"
    cat "$CONFIG_PATH"
    MUSIC_API_URL=$(jq -r '.music_api_url // "http://localhost:3001"' "$CONFIG_PATH")
    LOG_LEVEL=$(jq -r '.log_level // "info"' "$CONFIG_PATH")
fi

echo "Music API URL: $MUSIC_API_URL"
echo "Log Level: $LOG_LEVEL"

# 设置环境变量
export MUSIC_API_URL="$MUSIC_API_URL"

# 检查应用文件
echo "Checking application structure..."
find /app -name "*.js" -o -name "package.json" | head -10
ls -la /app/ || true

# 检查netease API目录
if [ -d "/app/netease-cloud-music-api" ]; then
    echo "Found netease-cloud-music-api directory"
    ls -la /app/netease-cloud-music-api/
elif [ -d "/app/server" ]; then
    echo "Found server directory"
    ls -la /app/server/
    # 更新supervisor配置指向正确目录
    sed -i 's|/app/netease-cloud-music-api|/app/server|g' /etc/supervisor.d/supervisord.conf
elif [ -f "/app/server.js" ]; then
    echo "Found server.js in /app"
    # 更新supervisor配置
    sed -i 's|directory=/app/netease-cloud-music-api|directory=/app|g' /etc/supervisor.d/supervisord.conf
else
    echo "Searching for server files..."
    find /app -name "server.js" -o -name "app.js" -o -name "index.js" | head -5
fi

# 检查和修复nginx配置
NGINX_CONF="/etc/nginx/nginx.conf"
if [ -f "$NGINX_CONF" ]; then
    echo "Using existing nginx configuration"
    # 确保API代理配置正确
    if ! grep -q "proxy_pass.*3000" "$NGINX_CONF"; then
        echo "Warning: nginx configuration may not include API proxy"
        cat "$NGINX_CONF"
    fi
else
    echo "Creating nginx configuration with API proxy"
    mkdir -p /etc/nginx
    cat > "$NGINX_CONF" << 'NGINX_EOF'
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    upstream netease_api {
        server 127.0.0.1:3000;
    }
    
    upstream music_api {
        server 127.0.0.1:3001;
    }

    server {
        listen 8080;
        server_name _;
        
        location / {
            root /usr/share/nginx/html;
            try_files $uri $uri/ /index.html;
        }
        
        # 内部网易云API代理
        location /api/ {
            proxy_pass http://netease_api/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_timeout 30s;
        }
        
        # 外部音乐API代理
        location /api_music/ {
            proxy_pass http://music_api/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_timeout 30s;
        }
    }
}
NGINX_EOF
fi

# 确保日志目录存在
mkdir -p /var/log/supervisor /var/log/nginx

echo "Starting services with supervisor..."
echo "- Netease API server on port 3000"
echo "- Nginx on port 8080"

# 使用supervisor启动所有服务
exec /usr/bin/supervisord -c /etc/supervisor.d/supervisord.conf
EOF

# 使脚本可执行
RUN chmod +x /ha-entrypoint.sh

# 暴露端口
EXPOSE 8080

# 使用新的入口点
CMD ["/ha-entrypoint.sh"]