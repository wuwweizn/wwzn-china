# ============================================================
# 构建阶段：固定 amd64，避免 lightningcss 在 armv7 无预编译二进制
# ============================================================
FROM --platform=linux/amd64 node:20-alpine AS builder

WORKDIR /app

# 视频源构建时硬编码（15个源）
ENV OKI_INITIAL_VIDEO_SOURCES='[{"id":"iqiyizyapi-com","name":"爱奇艺","url":"https://iqiyizyapi.com/api.php/provide/vod","detailUrl":"https://iqiyizyapi.com","isEnabled":true},{"id":"dbzy-tv","name":"豆瓣资源","url":"https://caiji.dbzy5.com/api.php/provide/vod","detailUrl":"https://dbzy.tv","isEnabled":true},{"id":"ikunzy-com","name":"iKun资源","url":"https://ikunzyapi.com/api.php/provide/vod","detailUrl":"https://ikunzy.com","isEnabled":true},{"id":"www-maoyanzy-com","name":"猫眼资源","url":"https://api.maoyanapi.top/api.php/provide/vod","detailUrl":"https://www.maoyanzy.com","isEnabled":true},{"id":"360zy-com","name":"360资源","url":"https://360zyzz.com/api.php/provide/vod","detailUrl":"https://360zy.com","isEnabled":true},{"id":"www-moduzy-net","name":"魔都资源","url":"https://www.mdzyapi.com/api.php/provide/vod","detailUrl":"https://www.moduzy.net","isEnabled":true},{"id":"xinlangapi-com","name":"新浪资源","url":"https://api.xinlangapi.com/xinlangapi.php/provide/vod","detailUrl":"https://xinlangapi.com","isEnabled":true},{"id":"www-subozy-com","name":"速播资源","url":"https://subocaiji.com/api.php/provide/vod","detailUrl":"https://www.subozy.com","isEnabled":true},{"id":"jinyingzy-com","name":"金鹰点播","url":"https://jinyingzy.com/api.php/provide/vod","detailUrl":"https://jinyingzy.com","isEnabled":true},{"id":"api-guangsuapi-com","name":"光速资源","url":"https://api.guangsuapi.com/api.php/provide/vod","detailUrl":"https://api.guangsuapi.com","isEnabled":true},{"id":"www-hongniuzy-com","name":"红牛资源","url":"https://www.hongniuzy2.com/api.php/provide/vod","detailUrl":"https://www.hongniuzy.com","isEnabled":true},{"id":"caiji-moduapi-cc","name":"魔都动漫","url":"https://caiji.moduapi.cc/api.php/provide/vod","detailUrl":"https://caiji.moduapi.cc","isEnabled":true},{"id":"www-ryzyw-com","name":"如意资源","url":"https://cj.rycjapi.com/api.php/provide/vod","detailUrl":"https://www.ryzyw.com","isEnabled":true},{"id":"www-haohuazy-com","name":"豪华资源","url":"https://hhzyapi.com/api.php/provide/vod","detailUrl":"https://www.haohuazy.com","isEnabled":true},{"id":"www-huyaapi-com","name":"虎牙资源","url":"https://www.huyaapi.com/api.php/provide/vod","detailUrl":"https://www.huyaapi.com","isEnabled":true}]'

ENV OKI_ACCESS_PASSWORD=""
ENV OKI_INITIAL_CONFIG=""
ENV OKI_DISABLE_ANALYTICS="true"

# TMDB 占位符（run.sh 运行时替换）
ENV OKI_TMDB_API_TOKEN="__OKI_TMDB_API_TOKEN__"
ENV OKI_TMDB_API_BASE_URL="__OKI_TMDB_API_BASE_URL__"
ENV OKI_TMDB_IMAGE_BASE_URL="__OKI_TMDB_IMAGE_BASE_URL__"

RUN apk add --no-cache git && \
    git clone --depth=1 https://github.com/Ouonnki/OuonnkiTV /app

RUN npm install -g pnpm@10.15.1 && \
    pnpm install --frozen-lockfile && \
    pnpm build

# ============================================================
# 运行阶段：node:alpine + nginx + supervisord（与上游一致）
# ============================================================
FROM node:20-alpine AS production

ARG BUILD_ARCH=amd64

LABEL \
  io.hass.name="OuonnkiTV" \
  io.hass.description="一键搭建个人影视站，支持TMDB智能模式，基于LibreTV修改" \
  io.hass.arch="${BUILD_ARCH}" \
  io.hass.type="addon" \
  maintainer="wuwweizn"

# 安装 nginx + supervisor + jq
RUN apk add --no-cache nginx supervisor jq && \
    rm -rf /var/cache/apk/*

# 创建必要目录
RUN mkdir -p /run/nginx /var/log/supervisor /app

WORKDIR /app

# 从上游克隆 proxy-server 和 shared（运行时需要）
RUN apk add --no-cache git && \
    git clone --depth=1 https://github.com/Ouonnki/OuonnkiTV /tmp/upstream && \
    cp /tmp/upstream/proxy-server.js /app/proxy-server.js && \
    cp -r /tmp/upstream/shared /app/shared && \
    rm -rf /tmp/upstream && \
    apk del git

# Node ESM 模式
RUN echo '{"type":"module"}' > /app/package.json

# 安装代理服务器依赖
RUN npm install --no-audit --no-fund express@4.21.2 cors@2.8.5 && \
    npm cache clean --force

# 复制前端构建产物
COPY --from=builder /app/dist /usr/share/nginx/html

# nginx 配置：监听 17380，代理 /proxy 到 Node 3001
RUN printf 'user nginx;\n\
worker_processes auto;\n\
error_log /var/log/nginx/error.log warn;\n\
pid /var/run/nginx.pid;\n\
events { worker_connections 1024; }\n\
http {\n\
    include /etc/nginx/mime.types;\n\
    default_type application/octet-stream;\n\
    server_tokens off;\n\
    sendfile on;\n\
    keepalive_timeout 65;\n\
    gzip on;\n\
    gzip_types text/plain text/css application/json application/javascript text/xml image/svg+xml;\n\
    server {\n\
        listen 17380;\n\
        server_name localhost;\n\
        root /usr/share/nginx/html;\n\
        index index.html;\n\
        location /proxy {\n\
            proxy_pass http://localhost:3001;\n\
            proxy_http_version 1.1;\n\
            proxy_set_header Host $host;\n\
            proxy_set_header X-Real-IP $remote_addr;\n\
            proxy_connect_timeout 30s;\n\
            proxy_send_timeout 60s;\n\
            proxy_read_timeout 60s;\n\
        }\n\
        location / {\n\
            try_files $uri $uri/ /index.html;\n\
        }\n\
        location = /index.html {\n\
            add_header Cache-Control "no-cache, no-store, must-revalidate";\n\
        }\n\
        location ~* \\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {\n\
            expires 1y;\n\
            add_header Cache-Control "public, immutable";\n\
        }\n\
    }\n\
}\n' > /etc/nginx/nginx.conf

# supervisord 配置：同时管理 nginx 和 proxy-server
RUN printf '[supervisord]\n\
nodaemon=true\n\
logfile=/var/log/supervisor/supervisord.log\n\
pidfile=/var/run/supervisord.pid\n\
\n\
[program:nginx]\n\
command=nginx -g '"'"'daemon off;'"'"'\n\
autostart=true\n\
autorestart=true\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
stderr_logfile=/dev/stderr\n\
stderr_logfile_maxbytes=0\n\
\n\
[program:proxy]\n\
command=node /app/proxy-server.js\n\
directory=/app\n\
autostart=true\n\
autorestart=true\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
stderr_logfile=/dev/stderr\n\
stderr_logfile_maxbytes=0\n' > /etc/supervisord.conf

COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 17380

CMD ["/run.sh"]