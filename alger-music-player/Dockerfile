# 第一阶段：提取原始应用
FROM banksiae/alger-music-player:latest as source-app

# 第二阶段：构建 UnblockNeteaseMusic
FROM node:18-alpine as unm-builder
WORKDIR /opt
RUN apk add --no-cache git
RUN git clone --depth=1 https://github.com/UnblockNeteaseMusic/server.git unm
WORKDIR /opt/unm
RUN npm install --production --no-audit && \
    npm cache clean --force && \
    # 验证必要文件
    test -f app.js && \
    echo "UnblockNeteaseMusic build complete"

# 第三阶段：构建最终镜像
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM ${BUILD_FROM}

# 设置构建参数
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# 设置标签
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}" \
    maintainer="wuwweizn" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="WWZN China Add-ons" \
    org.opencontainers.image.authors="wuwweizn" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/wuwweizn/wwzn-china" \
    org.opencontainers.image.source="https://github.com/wuwweizn/wwzn-china" \
    org.opencontainers.image.documentation="https://github.com/wuwweizn/wwzn-china/blob/main/alger-music-player/README.md" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.revision="${BUILD_REF}" \
    org.opencontainers.image.version="${BUILD_VERSION}"

# 设置环境变量
ENV \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    NODE_ENV=production \
    UNM_PORT=3001 \
    ALGER_PORT=3000 \
    UNM_SOURCE="netease qq kuwo kugou baidu migu" \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
    S6_CMD_WAIT_FOR_SERVICES=1

# 安装系统依赖
RUN apk add --no-cache \
    bash \
    nodejs \
    npm \
    nginx \
    curl \
    ca-certificates \
    supervisor \
    tzdata \
    net-tools \
    procps \
    && update-ca-certificates

# 创建用户和目录
RUN addgroup -g 1001 app && \
    adduser -D -s /bin/bash -u 1001 -G app app && \
    mkdir -p /app /opt/unm /var/log/nginx /run/nginx /etc/supervisor.d && \
    chown -R nginx:nginx /var/log/nginx /run/nginx

# 从第一阶段复制原始应用 - 更详细的复制
COPY --from=source-app /app /tmp/source-app
RUN cp -r /tmp/source-app/* /app/ 2>/dev/null || cp -r /tmp/source-app/. /app/ 2>/dev/null || true && \
    chown -R app:app /app && \
    # 验证关键文件是否存在
    ls -la /app/ && \
    echo "App directory contents:" && \
    find /app -type f -name "*.js" -o -name "*.json" | head -10

# 从第二阶段复制 UnblockNeteaseMusic
COPY --from=unm-builder /opt/unm /opt/unm
RUN chown -R app:app /opt/unm && \
    # 验证 UNM 文件
    test -f /opt/unm/app.js && \
    echo "UnblockNeteaseMusic files verified"

# 复制配置文件
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor.d/supervisord.conf

# 设置执行权限
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 创建必要的目录和文件
RUN mkdir -p /usr/share/nginx/html && \
    echo '<h1>Service Unavailable</h1>' > /usr/share/nginx/html/50x.html && \
    echo '<h1>Not Found</h1>' > /usr/share/nginx/html/404.html && \
    chown -R nginx:nginx /var/log/nginx /run/nginx

# 验证安装
RUN test -f /opt/unm/app.js && echo "✅ UnblockNeteaseMusic verified" && \
    ls -la /app/ && echo "✅ App directory verified" && \
    test -f /usr/local/bin/docker-entrypoint.sh && echo "✅ Entrypoint script verified"

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:3010/health || curl -f http://localhost:3010/ || exit 1

# 暴露端口
EXPOSE 3010

# 工作目录
WORKDIR /

# 启动命令
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]