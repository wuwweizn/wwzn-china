# 多阶段构建 - 提取原始应用和构建 UNM
FROM banksiae/alger-music-player:latest as source-app

FROM node:18-alpine as unm-builder
WORKDIR /opt
RUN apk add --no-cache git
RUN git clone --depth 1 https://github.com/UnblockNeteaseMusic/server.git unm
WORKDIR /opt/unm
RUN npm install --production --no-audit && npm cache clean --force

# 最终阶段 - 基于 Alpine Linux
FROM alpine:3.18

# 安装必要的包
RUN apk add --no-cache \
    bash \
    nodejs \
    npm \
    nginx \
    curl \
    ca-certificates \
    supervisor \
    tzdata \
    shadow \
    && update-ca-certificates

# 创建用户
RUN addgroup -g 1000 app && \
    adduser -D -s /bin/bash -u 1000 -G app app

# 设置环境变量
ENV LANG=C.UTF-8 \
    NODE_ENV=production \
    UNM_PORT=3001 \
    ALGER_PORT=3000

# 创建必要目录
RUN mkdir -p /app /opt/unm /var/log/nginx /run/nginx /etc/supervisor.d && \
    chown -R nginx:nginx /var/log/nginx /run/nginx && \
    chown -R app:app /app /opt/unm

# 从构建阶段复制文件
COPY --from=source-app --chown=app:app /app /app
COPY --from=unm-builder --chown=app:app /opt/unm /opt/unm

# 复制配置文件
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisord.conf

# 创建启动脚本
RUN cat > /usr/local/bin/start-services.sh << 'EOF' && chmod +x /usr/local/bin/start-services.sh
#!/bin/bash
set -e

echo "🎵 Starting Alger Music Player with UnblockNeteaseMusic..."

# 检查必要文件
if [ ! -f "/app/package.json" ]; then
    echo "⚠️  Warning: package.json not found, creating minimal version"
    cat > /app/package.json << 'EOJ'
{
  "name": "alger-music-player",
  "version": "1.0.0",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOJ
fi

if [ ! -f "/app/server.js" ]; then
    echo "⚠️  Warning: server.js not found, creating minimal version"
    cat > /app/server.js << 'EOS'
const express = require('express');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.static(path.join(__dirname, 'dist')));
app.get('/api/health', (req, res) => res.json({ status: 'ok' }));
app.get('*', (req, res) => res.sendFile(path.join(__dirname, 'dist', 'index.html')));

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Alger Music Player running on port ${PORT}`);
});
EOS

    mkdir -p /app/dist
    cat > /app/dist/index.html << 'EOH'
<!DOCTYPE html>
<html><head><title>Alger Music Player</title><meta charset="UTF-8">
<style>body{font-family:Arial,sans-serif;margin:0;padding:20px;background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);color:white;min-height:100vh;display:flex;align-items:center;justify-content:center;text-align:center}.container{background:rgba(255,255,255,0.1);padding:40px;border-radius:20px;backdrop-filter:blur(10px)}</style>
</head><body><div class="container"><h1>🎵 Alger Music Player</h1><p>UnblockNeteaseMusic 服务已启动</p><p>正在加载音乐播放器...</p></div></body></html>
EOH

    cd /app && npm install --production
fi

# 设置权限
chown -R app:app /app /opt/unm
chown -R nginx:nginx /var/log/nginx /run/nginx

echo "✅ Starting services with supervisor..."
exec /usr/bin/supervisord -c /etc/supervisord.conf
EOF

# 创建简化的 supervisor 配置
RUN cat > /etc/supervisord.conf << 'EOF'
[supervisord]
nodaemon=true
logfile=/var/log/supervisord.log
pidfile=/var/run/supervisord.pid
childlogdir=/var/log

[program:unm]
command=node app.js -p 3001 -o
directory=/opt/unm
user=app
autostart=true
autorestart=true
stderr_logfile=/var/log/unm_error.log
stdout_logfile=/var/log/unm_output.log

[program:alger-backend]
command=node server.js
directory=/app
user=app
autostart=true
autorestart=true
stderr_logfile=/var/log/alger_error.log
stdout_logfile=/var/log/alger_output.log
environment=PORT=3000

[program:nginx]
command=nginx -g "daemon off;"
autostart=true
autorestart=true
stderr_logfile=/var/log/nginx_error.log
stdout_logfile=/var/log/nginx_output.log
EOF

# 创建简化的 nginx 配置
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
    
    sendfile on;
    keepalive_timeout 65;
    
    server {
        listen 3010;
        server_name _;
        root /app/dist;
        index index.html;
        
        location / {
            try_files $uri $uri/ /index.html;
        }
        
        location /api/ {
            proxy_pass http://127.0.0.1:3000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
        
        location /api_music/ {
            rewrite ^/api_music/(.*) /$1 break;
            proxy_pass http://127.0.0.1:3001;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            add_header Access-Control-Allow-Origin *;
            add_header Access-Control-Allow-Methods 'GET, POST, OPTIONS';
        }
        
        location /health {
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:3010/health || exit 1

# 暴露端口
EXPOSE 3010

# 启动服务
CMD ["/usr/local/bin/start-services.sh"]