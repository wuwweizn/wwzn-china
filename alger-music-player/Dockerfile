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

# 创建启动脚本来处理配置并启动原始服务
RUN cat > /ha-start.sh << 'EOF'
#!/bin/bash
set -e

echo "=== Alger Music Player for Home Assistant ==="

# 读取 Home Assistant 配置
CONFIG_PATH="/data/options.json"
MUSIC_API_URL="http://localhost:3001"

if [ -f "$CONFIG_PATH" ]; then
    echo "Reading configuration from $CONFIG_PATH"
    cat "$CONFIG_PATH"
    MUSIC_API_URL=$(jq -r '.music_api_url // "http://localhost:3001"' "$CONFIG_PATH")
fi

echo "Music API URL: $MUSIC_API_URL"

# 设置环境变量（与原镜像保持一致）
export MUSIC_API_URL="$MUSIC_API_URL"

# 创建nginx配置文件添加API代理
if [ ! -f "/etc/nginx/conf.d/api-proxy.conf" ]; then
    echo "Adding API proxy configuration to nginx..."
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
    
    # 代理到内部API服务
    location /api/ {
        proxy_pass http://backend_api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_timeout 30s;
        proxy_connect_timeout 10s;
        
        # 添加CORS头部
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range' always;
    }
}
NGINX_EOF
fi

# 在后台启动原始应用的后端服务
echo "Starting backend API service..."
cd /app
if [ -f "start.sh" ]; then
    echo "Using existing start.sh script"
    chmod +x start.sh
    ./start.sh &
else
    echo "No start.sh found, trying to start node service manually..."
    # 检查是否有Node.js相关文件
    if [ -f "package.json" ]; then
        echo "Found package.json, checking for start script..."
        if npm run start > /dev/null 2>&1 &; then
            echo "Started with npm run start"
        else
            echo "npm start failed, trying direct node execution..."
            if [ -f "server.js" ]; then
                node server.js &
            elif [ -f "app.js" ]; then
                node app.js &
            elif [ -f "index.js" ]; then
                node index.js &
            fi
        fi
    fi
fi

# 等待后端服务启动
echo "Waiting for backend service to start..."
sleep 5

# 检查后端服务是否启动
if netstat -tlnp 2>/dev/null | grep :3000; then
    echo "✅ Backend API service started on port 3000"
else
    echo "⚠️ Backend API service may not be running on port 3000"
    echo "Current listening ports:"
    netstat -tlnp 2>/dev/null | grep LISTEN || echo "netstat not available"
fi

# 启动nginx
echo "Starting nginx on port 8080..."
exec nginx -g 'daemon off;'
EOF

# 使脚本可执行
RUN chmod +x /ha-start.sh

# 暴露端口
EXPOSE 8080

# 使用新的启动脚本
CMD ["/ha-start.sh"]