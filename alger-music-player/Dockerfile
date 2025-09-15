# 使用官方 Alger Music Player 镜像
FROM banksiae/alger-music-player:latest

# 添加标签信息
LABEL \
  io.hass.name="Alger Music Player" \
  io.hass.description="一个第三方音乐播放器，支持网易云音乐、本地服务、桌面歌词、音乐下载、远程控制" \
  io.hass.arch="aarch64|amd64|armv7" \
  io.hass.type="addon" \
  io.hass.version="1.0.5"

# 安装必要工具
RUN apk add --no-cache jq bash curl

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

# 设置环境变量（与原镜像保持一致）
export MUSIC_API_URL="$MUSIC_API_URL"

# 检查原始应用文件是否存在
if [ -d "/usr/share/nginx/html" ] && [ "$(ls -A /usr/share/nginx/html 2>/dev/null)" ]; then
    echo "Found application files in /usr/share/nginx/html"
else
    echo "Warning: Application files not found"
    ls -la /usr/share/nginx/ || true
    ls -la / || true
fi

# 检查nginx配置
if [ -f "/etc/nginx/nginx.conf" ]; then
    echo "Using existing nginx configuration"
else
    echo "Creating minimal nginx configuration"
    mkdir -p /etc/nginx
    cat > /etc/nginx/nginx.conf << 'NGINX_EOF'
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    server {
        listen 8080;
        server_name _;
        
        location / {
            root /usr/share/nginx/html;
            try_files $uri $uri/ /index.html;
        }
        
        location /api/ {
            proxy_pass http://127.0.0.1:3000;
            proxy_set_header Host $host;
        }
        
        location /api_music/ {
            proxy_pass http://127.0.0.1:3001;
            proxy_set_header Host $host;
        }
    }
}
NGINX_EOF
fi

# 启动nginx
echo "Starting nginx..."
exec nginx -g 'daemon off;'
EOF

# 使脚本可执行
RUN chmod +x /ha-entrypoint.sh

# 暴露端口
EXPOSE 8080

# 使用新的入口点
CMD ["/ha-entrypoint.sh"]