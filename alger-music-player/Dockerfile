ARG BUILD_FROM
FROM $BUILD_FROM

# 设置环境变量
ENV LANG=C.UTF-8 \
    NODE_ENV=production \
    UNM_PORT=3001 \
    ALGER_PORT=3000

# 安装必要的包
RUN apk add --no-cache \
    nodejs \
    npm \
    nginx \
    curl \
    bash \
    git \
    ca-certificates \
    supervisor

# 创建工作目录和用户
RUN addgroup -g 1001 app && \
    adduser -D -s /bin/bash -u 1001 -G app app

# 克隆并设置 UnblockNeteaseMusic
WORKDIR /opt
RUN git clone https://github.com/UnblockNeteaseMusic/server.git unm && \
    cd unm && \
    npm install --production --no-audit && \
    npm cache clean --force && \
    chown -R app:app /opt/unm

# 创建 Alger Music Player 应用目录
RUN mkdir -p /app && chown -R app:app /app

# 复制启动脚本（稍后会创建）
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 创建必要的目录
RUN mkdir -p /etc/nginx/conf.d \
    /var/log/nginx \
    /run/nginx \
    /etc/supervisor.d && \
    chown -R nginx:nginx /var/log/nginx /run/nginx

# 创建 nginx 配置文件
COPY nginx.conf /etc/nginx/nginx.conf

# 创建 supervisor 配置文件
COPY supervisord.conf /etc/supervisor.d/supervisord.conf

# 暴露端口
EXPOSE 3010

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:3010/ || exit 1

# 启动
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]