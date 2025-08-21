FROM nginx:alpine

# 复制网页文件
COPY ./web /usr/share/nginx/html

# 修改 nginx 配置，支持 history 模式路由
RUN echo 'server { \
    listen 80; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf
