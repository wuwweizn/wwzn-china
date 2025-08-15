FROM alpine:latest

# 安装必要的系统包
RUN apk add --no-cache \
        curl \
        bash \
        jq \
        nginx \
        supervisor \
        nodejs \
        npm \
        git

# 创建nginx用户和组
RUN addgroup -g 101 -S nginx && \
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx

# 创建必要的目录并设置权限
RUN mkdir -p /var/www/html \
    /var/log/nginx \
    /var/lib/nginx/tmp \
    /var/lib/nginx/body \
    /var/lib/nginx/fastcgi \
    /var/lib/nginx/proxy \
    /var/lib/nginx/scgi \
    /var/lib/nginx/uwsgi \
    /run/nginx \
    /var/log/supervisor \
    /etc/supervisor/conf.d \
    /var/cache/nginx

# 设置目录权限
RUN chown -R nginx:nginx /var/www/html \
    /var/log/nginx \
    /var/lib/nginx \
    /run/nginx \
    /var/cache/nginx && \
    chmod -R 755 /var/www/html \
    /var/log/nginx \
    /var/lib/nginx \
    /run/nginx

# 安装yarn
RUN npm install -g yarn

# 创建美观的启动页面
RUN cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>YesPlayMusic</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            color: white;
            padding: 1rem;
        }
        .container {
            text-align: center;
            max-width: 600px;
            padding: 2rem;
            background: rgba(255,255,255,0.1);
            border-radius: 20px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0,0,0,0.1);
        }
        .logo { font-size: 5rem; margin-bottom: 1rem; }
        .title { 
            font-size: 3rem; 
            margin-bottom: 1rem; 
            font-weight: 300; 
            text-shadow: 0 2px 10px rgba(0,0,0,0.3);
        }
        .subtitle { 
            font-size: 1.3rem; 
            opacity: 0.9; 
            margin-bottom: 2rem; 
            line-height: 1.5;
        }
        .status {
            background: rgba(255,255,255,0.2);
            padding: 1.5rem;
            border-radius: 12px;
            margin: 2rem 0;
            border: 1px solid rgba(255,255,255,0.2);
        }
        .btn {
            background: rgba(102, 126, 234, 0.8);
            border: 2px solid rgba(102, 126, 234, 1);
            color: white;
            padding: 1rem 2rem;
            border-radius: 30px;
            cursor: pointer;
            margin: 0.5rem;
            text-decoration: none;
            display: inline-block;
            font-weight: 500;
            transition: all 0.3s ease;
        }
        .btn:hover {
            background: rgba(102, 126, 234, 1);
            transform: translateY(-2px);
            box-shadow: 0 4px 20px rgba(0,0,0,0.2);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">🎵</div>
        <h1 class="title">YesPlayMusic</h1>
        <p class="subtitle">高颜值的第三方网易云播放器<br>现已在 Home Assistant 中运行</p>
        
        <div class="status">
            <p><strong>🎶 欢迎使用 YesPlayMusic！</strong></p>
            <p>服务正在运行中，您可以开始享受音乐了。</p>
        </div>
        
        <div>
            <a href="https://music.qier222.com" target="_blank" class="btn">
                🚀 打开 YesPlayMusic
            </a>
        </div>
        
        <div style="margin-top: 2rem; font-size: 0.9rem; opacity: 0.8;">
            <p>💡 提示：建议登录网易云账号获得完整功能</p>
            <p>🔗 支持扫码登录、手机号登录、邮箱登录</p>
        </div>
    </div>
</body>
</html>
EOF

# 复制配置文件
COPY rootfs /

# 创建基础nginx配置
RUN cat > /etc/nginx/nginx.conf << 'EOF'
user nginx;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log warn;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    access_log /var/log/nginx/access.log;
    sendfile on;
    keepalive_timeout 65;
    
    server {
        listen 80;
        server_name _;
        root /var/www/html;
        index index.html;
        
        location / {
            try_files $uri $uri/ /index.html;
        }
        
        location /api/ {
            proxy_pass https://music-api.hankqin.com/;
            proxy_set_header Host music-api.hankqin.com;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_ssl_verify off;
            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
        }
    }
}
EOF

# 测试nginx配置
RUN nginx -t

# 设置脚本权限
RUN chmod +x /usr/local/bin/run.sh /usr/local/bin/setup_nginx.sh

# 尝试构建YesPlayMusic（可选）
RUN echo "Attempting to build YesPlayMusic..." && \
    (git clone --depth 1 https://github.com/qier222/YesPlayMusic.git /tmp/build && \
     cd /tmp/build && \
     echo 'VUE_APP_NETEASE_API_URL=/api' > .env && \
     timeout 600 yarn install --frozen-lockfile --network-timeout 60000 --ignore-engines && \
     timeout 300 yarn build && \
     cp -r dist/* /var/www/html/ && \
     echo "YesPlayMusic built successfully" && \
     chown -R nginx:nginx /var/www/html) || \
    echo "Build failed or timed out, using fallback interface"

# 清理构建缓存
RUN rm -rf /tmp/build /root/.npm /root/.yarn-cache 2>/dev/null || true

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# 暴露端口
EXPOSE 80

# 环境变量
ENV NETEASE_API_URL=https://music-api.hankqin.com
ENV SSL=false

# 标签
LABEL \
    io.hass.name="YesPlayMusic" \
    io.hass.description="高颜值的第三方网易云播放器" \
    io.hass.type="addon" \
    io.hass.version="1.0.6"

# 启动命令
CMD ["/usr/local/bin/run.sh"]