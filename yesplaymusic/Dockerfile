# 构建阶段
FROM node:18-alpine as builder

WORKDIR /app

# 安装构建依赖
RUN apk add --no-cache git python3 make g++

# 克隆YesPlayMusic源码
RUN git clone --depth 1 https://github.com/qier222/YesPlayMusic.git .

# 创建环境配置文件
RUN echo 'VUE_APP_NETEASE_API_URL=/api' > .env

# 安装依赖并构建
RUN npm install -g yarn && \
    yarn install --frozen-lockfile --network-timeout 100000 && \
    yarn build

# 运行阶段
FROM alpine:latest

# 安装运行依赖
RUN apk add --no-cache curl bash jq nginx supervisor

# 创建nginx用户
RUN addgroup -g 101 -S nginx && \
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx

# 创建必要目录
RUN mkdir -p /var/www/html \
    /var/log/nginx \
    /var/lib/nginx/tmp \
    /run/nginx \
    /var/log/supervisor \
    /etc/supervisor/conf.d \
    /var/cache/nginx

# 从构建阶段复制文件
COPY --from=builder /app/dist /var/www/html

# 创建备用HTML文件（分离到独立文件中）
COPY fallback.html /tmp/fallback.html

# 检查构建结果，如果失败则使用备用文件
RUN if [ ! -f "/var/www/html/index.html" ] || [ ! -d "/var/www/html/assets" ]; then \
        echo "Using fallback HTML..." && \
        cp /tmp/fallback.html /var/www/html/index.html; \
    fi && \
    rm -f /tmp/fallback.html

# 复制配置文件
COPY rootfs /

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
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript;
    
    server {
        listen 80;
        server_name _;
        root /var/www/html;
        index index.html;
        
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
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
            
            if ($request_method = 'OPTIONS') {
                add_header 'Access-Control-Allow-Origin' '*';
                add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS';
                add_header 'Access-Control-Max-Age' 1728000;
                add_header 'Content-Type' 'text/plain; charset=utf-8';
                add_header 'Content-Length' 0;
                return 204;
            }
        }
        
        location / {
            try_files $uri $uri/ /index.html;
        }
    }
}
EOF

# 设置权限
RUN chown -R nginx:nginx /var/www/html /var/log/nginx /var/lib/nginx /run/nginx /var/cache/nginx && \
    chmod +x /usr/local/bin/run.sh

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
    io.hass.description="高颜值的第三方网易云播放器 - 稳定版" \
    io.hass.type="addon" \
    io.hass.version="1.0.8"

# 启动命令
CMD ["/usr/local/bin/run.sh"]