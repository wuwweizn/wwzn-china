FROM node:18-alpine as builder

# 设置工作目录
WORKDIR /app

# 安装必要的构建工具
RUN apk add --no-cache git python3 make g++

# 克隆YesPlayMusic源码
RUN git clone --depth 1 https://github.com/qier222/YesPlayMusic.git .

# 配置环境变量
RUN echo 'VUE_APP_NETEASE_API_URL=/api' > .env

# 安装依赖并构建
RUN yarn install --frozen-lockfile --network-timeout 120000 && \
    yarn build

# 生产阶段
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

# 创建必要目录
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

# 从构建阶段复制应用文件
COPY --from=builder /app/dist /var/www/html/

# 如果构建失败，创建备用页面
RUN if [ ! -f "/var/www/html/index.html" ]; then \
        echo "Creating fallback interface..." && \
        cat > /var/www/html/index.html << 'EOF'
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
            color: white;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 2rem;
            text-align: center;
        }
        .header {
            margin-bottom: 3rem;
        }
        .logo { font-size: 6rem; margin-bottom: 1rem; }
        .title { font-size: 3.5rem; margin-bottom: 1rem; font-weight: 300; }
        .subtitle { font-size: 1.4rem; opacity: 0.9; margin-bottom: 2rem; }
        .main {
            background: rgba(255,255,255,0.1);
            border-radius: 20px;
            padding: 3rem;
            margin-bottom: 2rem;
            backdrop-filter: blur(10px);
        }
        .error-info {
            background: rgba(255,107,107,0.2);
            border: 1px solid rgba(255,107,107,0.3);
            border-radius: 12px;
            padding: 2rem;
            margin: 2rem 0;
        }
        .solution {
            background: rgba(76,175,80,0.2);
            border: 1px solid rgba(76,175,80,0.3);
            border-radius: 12px;
            padding: 2rem;
            margin: 2rem 0;
            text-align: left;
        }
        .btn {
            background: rgba(102,126,234,0.8);
            border: 2px solid rgba(102,126,234,1);
            color: white;
            padding: 1rem 2rem;
            border-radius: 30px;
            text-decoration: none;
            display: inline-block;
            margin: 0.5rem;
            transition: all 0.3s ease;
            cursor: pointer;
        }
        .btn:hover {
            background: rgba(102,126,234,1);
            transform: translateY(-2px);
        }
        .code {
            background: rgba(0,0,0,0.3);
            padding: 1rem;
            border-radius: 8px;
            font-family: monospace;
            margin: 1rem 0;
            text-align: left;
            overflow-x: auto;
        }
        .steps {
            text-align: left;
            margin: 2rem 0;
        }
        .steps ol {
            padding-left: 1.5rem;
        }
        .steps li {
            margin: 1rem 0;
            line-height: 1.6;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">🎵</div>
            <h1 class="title">YesPlayMusic</h1>
            <p class="subtitle">高颜值的第三方网易云播放器</p>
        </div>
        
        <div class="main">
            <div class="error-info">
                <h3>⚠️ 服务暂时不可用</h3>
                <p>YesPlayMusic的官方演示站点已暂停服务，但您仍然可以在本地使用完整功能！</p>
            </div>
            
            <div class="solution">
                <h3>💡 解决方案</h3>
                <div class="steps">
                    <p><strong>方案1：安装桌面版本（推荐）</strong></p>
                    <ol>
                        <li>访问 <a href="https://github.com/qier222/YesPlayMusic/releases" target="_blank" style="color: #4fc3f7;">GitHub Releases 页面</a></li>
                        <li>下载适合您系统的安装包</li>
                        <li>安装后即可使用完整功能</li>
                    </ol>
                    
                    <p><strong>方案2：自建部署</strong></p>
                    <ol>
                        <li>部署网易云音乐API服务器</li>
                        <li>构建并部署YesPlayMusic前端</li>
                        <li>配置API地址连接</li>
                    </ol>
                </div>
            </div>
            
            <div style="margin: 2rem 0;">
                <h3>🎶 YesPlayMusic 功能特色</h3>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin: 1.5rem 0; text-align: left;">
                    <div style="background: rgba(255,255,255,0.1); padding: 1rem; border-radius: 8px;">
                        <strong>🔐 账号登录</strong><br>
                        支持网易云账号登录
                    </div>
                    <div style="background: rgba(255,255,255,0.1); padding: 1rem; border-radius: 8px;">
                        <strong>📺 MV播放</strong><br>
                        支持高清MV播放
                    </div>
                    <div style="background: rgba(255,255,255,0.1); padding: 1rem; border-radius: 8px;">
                        <strong>📃 歌词显示</strong><br>
                        实时歌词同步显示
                    </div>
                    <div style="background: rgba(255,255,255,0.1); padding: 1rem; border-radius: 8px;">
                        <strong>📻 私人FM</strong><br>
                        个性化推荐音乐
                    </div>
                    <div style="background: rgba(255,255,255,0.1); padding: 1rem; border-radius: 8px;">
                        <strong>☁️ 音乐云盘</strong><br>
                        同步云端音乐库
                    </div>
                    <div style="background: rgba(255,255,255,0.1); padding: 1rem; border-radius: 8px;">
                        <strong>🌚 主题切换</strong><br>
                        深色/浅色模式
                    </div>
                </div>
            </div>
            
            <div>
                <a href="https://github.com/qier222/YesPlayMusic/releases" target="_blank" class="btn">
                    📦 下载桌面版
                </a>
                <a href="https://github.com/qier222/YesPlayMusic" target="_blank" class="btn">
                    📖 查看源码
                </a>
                <button onclick="location.reload()" class="btn">
                    🔄 刷新页面
                </button>
            </div>
            
            <div style="margin-top: 3rem; font-size: 0.9rem; opacity: 0.7;">
                <p>💡 提示：桌面版本功能更加完整，推荐下载使用</p>
                <p>🔗 如需自建部署，请参考项目文档说明</p>
            </div>
        </div>
    </div>
    
    <script>
        // 尝试检测是否有可用的在线版本
        function checkOnlineVersion() {
            const testUrls = [
                'https://music.qier222.com',
                'https://zhangjj295.github.io/YesPlayMusic/'
            ];
            
            testUrls.forEach(url => {
                fetch(url, { mode: 'no-cors', method: 'HEAD' })
                    .then(() => {
                        const btn = document.createElement('a');
                        btn.href = url;
                        btn.target = '_blank';
                        btn.className = 'btn';
                        btn.textContent = '🌐 尝试在线版本';
                        btn.style.background = 'rgba(76,175,80,0.8)';
                        btn.style.borderColor = 'rgba(76,175,80,1)';
                        document.querySelector('div:last-child').appendChild(btn);
                    })
                    .catch(() => {
                        // 忽略错误
                    });
            });
        }
        
        // 页面加载后检查在线版本
        setTimeout(checkOnlineVersion, 2000);
    </script>
</body>
</html>
EOF
    fi

# 创建nginx配置
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
    gzip_vary on;
    gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss;
    
    server {
        listen 80;
        server_name _;
        root /var/www/html;
        index index.html;
        
        # 静态文件
        location / {
            try_files $uri $uri/ /index.html;
            
            # 缓存静态资源
            location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
                expires 1y;
                add_header Cache-Control "public, immutable";
                add_header Access-Control-Allow-Origin "*";
            }
        }
        
        # API代理
        location /api/ {
            proxy_pass https://music-api.hankqin.com/;
            proxy_set_header Host music-api.hankqin.com;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header User-Agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36";
            proxy_ssl_verify off;
            
            # CORS
            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
            add_header 'Access-Control-Allow-Credentials' 'true' always;
            
            # OPTIONS请求处理
            if ($request_method = 'OPTIONS') {
                add_header 'Access-Control-Allow-Origin' '*';
                add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS';
                add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization';
                add_header 'Access-Control-Max-Age' 1728000;
                add_header 'Content-Type' 'text/plain; charset=utf-8';
                add_header 'Content-Length' 0;
                return 204;
            }
        }
    }
}
EOF

# 创建supervisor配置
RUN cat > /etc/supervisor/conf.d/supervisord.conf << 'EOF'
[supervisord]
nodaemon=true
user=root
logfile=/var/log/supervisor/supervisord.log
pidfile=/var/run/supervisord.pid

[program:nginx]
command=/usr/sbin/nginx -g "daemon off;"
autostart=true
autorestart=true
stderr_logfile=/var/log/supervisor/nginx.err.log
stdout_logfile=/var/log/supervisor/nginx.out.log
user=root

[unix_http_server]
file=/var/run/supervisor.sock
chmod=0700

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///var/run/supervisor.sock
EOF

# 创建启动脚本
RUN cat > /usr/local/bin/run.sh << 'EOF'
#!/bin/bash
set -e

echo "Starting YesPlayMusic..."

# 创建必要目录
mkdir -p /var/log/supervisor /var/log/nginx /run/nginx

# 设置权限
chown -R nginx:nginx /var/www/html /var/log/nginx /run/nginx /var/lib/nginx

# 测试nginx配置
nginx -t

echo "Starting supervisor..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
EOF

# 设置权限
RUN chown -R nginx:nginx /var/www/html \
    /var/log/nginx \
    /var/lib/nginx \
    /run/nginx \
    /var/cache/nginx && \
    chmod +x /usr/local/bin/run.sh

# 测试nginx配置
RUN nginx -t

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# 暴露端口
EXPOSE 80

# 标签
LABEL \
    io.hass.name="YesPlayMusic" \
    io.hass.description="高颜值的第三方网易云播放器" \
    io.hass.type="addon" \
    io.hass.version="1.0.7"

# 启动命令
CMD ["/usr/local/bin/run.sh"]