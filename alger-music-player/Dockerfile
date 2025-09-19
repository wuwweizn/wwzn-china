# 使用官方 Alger Music Player 镜像
FROM banksiae/alger-music-player:latest

# 添加标签信息
LABEL \
  io.hass.name="Alger Music Player" \
  io.hass.description="一个第三方音乐播放器，支持网易云音乐、本地服务、桌面歌词、音乐下载、远程控制" \
  io.hass.arch="aarch64|amd64|armv7" \
  io.hass.type="addon" \
  io.hass.version="1.0.0"

# 安装必要工具
RUN apk add --no-cache jq bash curl

# 创建启动脚本
RUN cat > /ha-start.sh << 'EOF'
#!/bin/bash
set -e

echo "=== Alger Music Player for Home Assistant ==="

# 读取 Home Assistant 配置
CONFIG_PATH="/data/options.json"
MUSIC_API_URL="http://localhost:3001"

if [ -f "$CONFIG_PATH" ]; then
    echo "Reading configuration:"
    cat "$CONFIG_PATH"
    MUSIC_API_URL=$(jq -r '.music_api_url // "http://localhost:3001"' "$CONFIG_PATH")
fi

echo "Music API URL: $MUSIC_API_URL"
export MUSIC_API_URL="$MUSIC_API_URL"

# 添加nginx API代理配置
echo "Configuring nginx proxy..."
cat > /etc/nginx/conf.d/api-proxy.conf << 'NGINX_EOF'
upstream backend_api {
    server 127.0.0.1:3000;
}

server {
    listen 8080;
    server_name _;
    root /usr/share/nginx/html;
    index index.html index.htm;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    location /api/ {
        proxy_pass http://backend_api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_timeout 30s;
        proxy_connect_timeout 10s;
        
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range' always;
    }
}
NGINX_EOF

# 启动后端API服务
echo "Starting backend API service..."
cd /app

# 检查启动脚本
if [ -f "start.sh" ]; then
    echo "Found start.sh script"
    chmod +x start.sh
    echo "Executing start.sh in background..."
    ./start.sh &
    BACKEND_PID=$!
    echo "Backend started with PID: $BACKEND_PID"
else
    echo "No start.sh found, checking package.json..."
    if [ -f "package.json" ]; then
        echo "Trying npm run start..."
        npm run start &
        BACKEND_PID=$!
        echo "Backend started with PID: $BACKEND_PID"
    else
        echo "No package.json found either"
    fi
fi

# 等待服务启动
echo "Waiting for backend service to initialize..."
sleep 8

# 检查服务状态
echo "Checking service status..."
if command -v netstat >/dev/null 2>&1; then
    LISTENING=$(netstat -tlnp 2>/dev/null | grep ":3000" || echo "")
    if [ -n "$LISTENING" ]; then
        echo "✅ Backend API service is running on port 3000"
        echo "$LISTENING"
    else
        echo "⚠️ Port 3000 not detected in netstat"
    fi
else
    echo "netstat not available for port checking"
fi

# 检查进程
echo "Active processes:"
ps aux | grep -E "(node|npm)" | grep -v grep || echo "No node/npm processes found"

# 启动nginx
echo "Starting nginx on port 8080..."
exec nginx -g 'daemon off;'
EOF

# 使脚本可执行
RUN chmod +x /ha-start.sh

# 暴露端口
EXPOSE 8080

# 使用启动脚本
CMD ["/ha-start.sh"]