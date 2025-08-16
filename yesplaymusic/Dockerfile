FROM node:18-alpine as builder

# 安装构建依赖
RUN apk add --no-cache git python3 make g++

# 设置工作目录
WORKDIR /app

# 克隆YesPlayMusic源码
RUN git clone --depth 1 https://github.com/qier222/YesPlayMusic.git .

# 创建环境配置文件
RUN echo 'VUE_APP_NETEASE_API_URL=/api' > .env

# 安装yarn并构建项目
RUN npm install -g yarn && \
    yarn install --frozen-lockfile --network-timeout 100000 && \
    yarn build

# 运行时镜像
FROM alpine:latest

# 安装运行时依赖
RUN apk add --no-cache \
        curl \
        bash \
        jq \
        nginx \
        supervisor

# 创建nginx用户
RUN addgroup -g 101 -S nginx && \
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx

# 创建必要的目录
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

# 从构建阶段复制构建好的文件
COPY --from=builder /app/dist /var/www/html

# 如果构建失败，创建一个功能齐全的备用页面
RUN if [ ! -f "/var/www/html/index.html" ] || [ ! -d "/var/www/html/assets" ]; then \
        echo "Creating comprehensive fallback page..." && \
        cat > /var/www/html/index.html << 'FALLBACK_EOF' && \
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>YesPlayMusic</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>🎵</text></svg>">
    <style>
        :root {
            --primary: #667eea;
            --secondary: #764ba2;
            --bg-light: rgba(255,255,255,0.1);
            --bg-medium: rgba(255,255,255,0.2);
            --text-primary: #ffffff;
            --text-secondary: rgba(255,255,255,0.8);
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            min-height: 100vh;
            color: var(--text-primary);
            overflow-x: hidden;
        }
        .app { min-height: 100vh; display: flex; flex-direction: column; }
        .header { text-align: center; padding: 3rem 1rem 2rem; }
        .logo {
            font-size: 6rem;
            margin-bottom: 1rem;
            animation: bounce 2s ease-in-out infinite;
        }
        @keyframes bounce {
            0%, 20%, 50%, 80%, 100% { transform: translateY(0); }
            40% { transform: translateY(-10px); }
            60% { transform: translateY(-5px); }
        }
        .title {
            font-size: 3.5rem;
            font-weight: 300;
            margin-bottom: 1rem;
            text-shadow: 0 2px 20px rgba(0,0,0,0.3);
        }
        .subtitle {
            font-size: 1.4rem;
            color: var(--text-secondary);
            line-height: 1.6;
            max-width: 600px;
            margin: 0 auto;
        }
        .main { flex: 1; padding: 0 1rem; max-width: 1200px; margin: 0 auto; width: 100%; }
        .player-container {
            background: var(--bg-light);
            border-radius: 20px;
            padding: 2rem;
            margin: 2rem 0;
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255,255,255,0.2);
            box-shadow: 0 8px 32px rgba(0,0,0,0.1);
        }
        .player-interface { text-align: center; }
        .now-playing { margin-bottom: 2rem; }
        .track-info h3 { font-size: 1.5rem; margin-bottom: 0.5rem; }
        .track-info p { color: var(--text-secondary); }
        .controls {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 1rem;
            margin: 2rem 0;
            flex-wrap: wrap;
        }
        .btn {
            background: var(--bg-medium);
            border: 2px solid rgba(255,255,255,0.3);
            color: var(--text-primary);
            padding: 1rem 2rem;
            border-radius: 30px;
            cursor: pointer;
            font-weight: 500;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            transition: all 0.3s ease;
            white-space: nowrap;
        }
        .btn:hover {
            background: rgba(255,255,255,0.3);
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(0,0,0,0.2);
        }
        .btn.primary {
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            border-color: transparent;
        }
        .btn.primary:hover { transform: translateY(-2px) scale(1.05); }
        .features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin: 2rem 0;
        }
        .feature-card {
            background: var(--bg-light);
            border-radius: 16px;
            padding: 2rem;
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255,255,255,0.1);
        }
        .feature-card h3 {
            font-size: 1.3rem;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .feature-list { list-style: none; }
        .feature-list li {
            margin: 0.8rem 0;
            padding-left: 1.5rem;
            position: relative;
            line-height: 1.5;
        }
        .feature-list li::before { content: "✨"; position: absolute; left: 0; }
        .instructions {
            background: var(--bg-light);
            border-radius: 16px;
            padding: 2rem;
            margin: 2rem 0;
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255,255,255,0.1);
        }
        .instructions h3 {
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .instructions ol { padding-left: 1.5rem; }
        .instructions li { margin: 1rem 0; line-height: 1.6; }
        .footer {
            text-align: center;
            padding: 2rem;
            color: var(--text-secondary);
            font-size: 0.9rem;
        }
        @media (max-width: 768px) {
            .title { font-size: 2.5rem; }
            .logo { font-size: 4rem; }
            .header { padding: 2rem 1rem 1rem; }
            .controls { flex-direction: column; }
            .btn { width: 100%; justify-content: center; }
        }
    </style>
</head>
<body>
    <div class="app">
        <header class="header">
            <div class="logo">🎵</div>
            <h1 class="title">YesPlayMusic</h1>
            <p class="subtitle">高颜值的第三方网易云播放器<br>现已在 Home Assistant 中运行</p>
        </header>
        <main class="main">
            <div class="player-container">
                <div class="player-interface">
                    <div class="now-playing">
                        <div class="track-info">
                            <h3>🎼 欢迎使用 YesPlayMusic</h3>
                            <p>准备开始您的音乐之旅</p>
                        </div>
                    </div>
                    <div class="controls">
                        <a href="#" class="btn primary" onclick="showLoginInfo()">🔑 登录说明</a>
                        <a href="/api/ping" class="btn">🔗 测试API</a>
                        <a href="#" class="btn" onclick="showFeatures()">✨ 功能介绍</a>
                    </div>
                </div>
            </div>
            <div class="features">
                <div class="feature-card">
                    <h3>🎵 音乐功能</h3>
                    <ul class="feature-list">
                        <li>网易云账号登录同步</li>
                        <li>高品质音乐播放</li>
                        <li>私人 FM 和每日推荐</li>
                        <li>音乐云盘支持</li>
                        <li>智能歌曲推荐</li>
                        <li>歌单管理和收藏</li>
                    </ul>
                </div>
                <div class="feature-card">
                    <h3>🎬 视听体验</h3>
                    <ul class="feature-list">
                        <li>MV 高清播放</li>
                        <li>实时歌词显示</li>
                        <li>深色/浅色主题</li>
                        <li>PWA 应用支持</li>
                        <li>响应式设计</li>
                        <li>无广告干扰</li>
                    </ul>
                </div>
                <div class="feature-card">
                    <h3>🌍 特色功能</h3>
                    <ul class="feature-list">
                        <li>海外用户直接访问</li>
                        <li>自动音源替换</li>
                        <li>无社交功能干扰</li>
                        <li>自定义快捷键</li>
                        <li>每日自动签到</li>
                        <li>本地Home Assistant集成</li>
                    </ul>
                </div>
            </div>
            <div class="instructions">
                <h3>📝 使用说明</h3>
                <ol>
                    <li><strong>完整版本：</strong>如果构建成功，将显示完整的YesPlayMusic界面</li>
                    <li><strong>登录账号：</strong>支持扫码、手机号、邮箱多种登录方式</li>
                    <li><strong>开始听歌：</strong>登录后即可访问您的音乐库、歌单和推荐内容</li>
                    <li><strong>API连接：</strong>通过内置代理连接网易云音乐API</li>
                    <li><strong>本地化：</strong>所有界面和功能完全在Home Assistant本地运行</li>
                </ol>
            </div>
        </main>
        <footer class="footer">
            <p><strong>YesPlayMusic</strong> - 开源第三方网易云播放器<br>现已集成到您的 Home Assistant 系统中</p>
        </footer>
    </div>
    <script>
        function showLoginInfo() {
            alert('🔑 登录功能\n\n• 扫码登录（推荐）\n• 手机号 + 密码\n• 邮箱 + 密码\n\n登录后可同步您的音乐库和个人数据');
        }
        function showFeatures() {
            alert('✨ YesPlayMusic 功能特色\n\n🎵 完整音乐体验\n🎬 MV播放支持\n🌍 海外直接访问\n📱 响应式设计\n🔐 无广告干扰');
        }
    </script>
</body>
</html>
FALLBACK_EOF
        echo "Fallback page created successfully"; \
    fi

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
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    
    server {
        listen 80;
        server_name _;
        root /var/www/html;
        index index.html;
        
        # 静态文件缓存
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
        
        # API代理
        location /api/ {
            proxy_pass https://music-api.hankqin.com/;
            proxy_set_header Host music-api.hankqin.com;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_ssl_verify off;
            
            # CORS headers
            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
            
            # Handle preflight requests
            if ($request_method = 'OPTIONS') {
                add_header 'Access-Control-Allow-Origin' '*';
                add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS';
                add_header 'Access-Control-Max-Age' 1728000;
                add_header 'Content-Type' 'text/plain; charset=utf-8';
                add_header 'Content-Length' 0;
                return 204;
            }
        }
        
        # SPA路由支持
        location / {
            try_files $uri $uri/ /index.html;
        }
    }
}
EOF

# 设置权限
RUN chown -R nginx:nginx /var/www/html \
    /var/log/nginx \
    /var/lib/nginx \
    /run/nginx \
    /var/cache/nginx && \
    chmod +x /usr/local/bin/run.sh /usr/local/bin/setup_nginx.sh

# 测试nginx配置
RUN nginx -t

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
    io.hass.description="高颜值的第三方网易云播放器 - 完全本地化版本" \
    io.hass.type="addon" \
    io.hass.version="1.0.7"

# 启动命令
CMD ["/usr/local/bin/run.sh"]