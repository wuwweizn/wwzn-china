ARG BUILD_FROM
FROM $BUILD_FROM as base

# 设置环境变量
ENV LANG=C.UTF-8
ENV MUSIC_API_URL=http://localhost:3001
ENV NODE_ENV=production
ENV UNM_PORT=3001

# 安装必要的包
RUN apk add --no-cache \
    nodejs \
    npm \
    nginx \
    curl \
    bash \
    git \
    ca-certificates \
    && update-ca-certificates

# 创建工作目录
WORKDIR /app

# 第一阶段：构建 UnblockNeteaseMusic
FROM base as unm-builder
WORKDIR /tmp
RUN git clone https://github.com/UnblockNeteaseMusic/server.git unm \
    && cd unm \
    && npm install --production \
    && npm cache clean --force

# 第二阶段：构建最终镜像
FROM base as final

# 复制原始应用
COPY --from=banksiae/alger-music-player:latest /app /app
COPY --from=banksiae/alger-music-player:latest /etc/nginx /etc/nginx

# 复制 UnblockNeteaseMusic
COPY --from=unm-builder /tmp/unm /opt/unm

# 创建必要的目录
RUN mkdir -p /etc/services.d/alger-music \
    && mkdir -p /etc/services.d/unm \
    && mkdir -p /var/log/nginx

# 复制配置文件和脚本
COPY rootfs /

# 创建自定义的 nginx 配置
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
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json;
    
    # Alger Music Player 主服务
    upstream backend {
        server 127.0.0.1:3000;
    }
    
    # UnblockNeteaseMusic 服务
    upstream unm {
        server 127.0.0.1:3001;
    }
    
    server {
        listen 3010;
        server_name _;
        root /app/dist;
        index index.html index.htm;
        
        # 静态文件服务
        location / {
            try_files $uri $uri/ /index.html;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            add_header Pragma "no-cache";
            add_header Expires "0";
        }
        
        # 后端 API 代理
        location /api/ {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }
        
        # 音乐 API 代理（支持外部和内置 UNM）
        location /api_music/ {
            # 移除前缀
            rewrite ^/api_music/(.*) /$1 break;
            
            # 检查是否配置了外部音乐 API
            set $api_backend unm;
            if ($arg_external = "1") {
                set $api_backend $music_api_url;
            }
            
            proxy_pass http://$api_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_connect_timeout 30s;
            proxy_send_timeout 30s;
            proxy_read_timeout 30s;
            
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
    }
}
EOF

# 设置权限
RUN chmod +x /etc/services.d/alger-music/run \
    && chmod +x /etc/services.d/alger-music/finish \
    && chmod +x /etc/services.d/unm/run \
    && chmod +x /etc/services.d/unm/finish \
    && chown -R nginx:nginx /var/log/nginx \
    && mkdir -p /run/nginx

# 暴露端口
EXPOSE 3010

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:3010/ || exit 1

# 设置启动脚本
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]