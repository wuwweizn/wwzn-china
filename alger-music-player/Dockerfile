# 第一阶段：提取原始应用
FROM banksiae/alger-music-player:latest as source-app

# 第二阶段：构建 UnblockNeteaseMusic
FROM node:18-alpine as unm-builder
WORKDIR /opt
RUN apk add --no-cache git
RUN git clone https://github.com/UnblockNeteaseMusic/server.git unm
WORKDIR /opt/unm
RUN npm install --production --no-audit && \
    npm cache clean --force

# 第三阶段：构建最终镜像
ARG BUILD_FROM
FROM $BUILD_FROM

# 设置标签
LABEL \
    io.hass.name="Alger Music Player" \
    io.hass.description="网易云音乐播放器，支持高音质播放和内置UnblockNeteaseMusic服务" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}" \
    maintainer="wuwweizn" \
    org.opencontainers.image.title="Alger Music Player Add-on" \
    org.opencontainers.image.description="网易云音乐播放器 Home Assistant 加载项" \
    org.opencontainers.image.source="https://github.com/wuwweizn/wwzn-china"

# 设置环境变量
ENV \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    NODE_ENV=production \
    UNM_PORT=3001 \
    ALGER_PORT=3000 \
    UNM_SOURCE="netease qq kuwo kugou baidu migu"

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
    && update-ca-certificates

# 创建用户和目录
RUN addgroup -g 1001 app && \
    adduser -D -s /bin/bash -u 1001 -G app app && \
    mkdir -p /app /opt/unm /var/log/nginx /run/nginx /etc/supervisor.d && \
    chown -R nginx:nginx /var/log/nginx /run/nginx

# 从第一阶段复制原始应用
COPY --from=source-app --chown=app:app /app /app

# 从第二阶段复制 UnblockNeteaseMusic
COPY --from=unm-builder --chown=app:app /opt/unm /opt/unm

# 复制配置文件
COPY --chown=root:root rootfs/ /

# 创建 nginx 配置
COPY --chown=nginx:nginx nginx.conf /etc/nginx/nginx.conf

# 创建 supervisor 配置
COPY --chown=root:root supervisord.conf /etc/supervisor.d/supervisord.conf

# 创建启动脚本
COPY --chown=root:root docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# 设置执行权限
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    find /etc/services.d -name "run" -o -name "finish" | xargs chmod +x

# 验证必要文件
RUN test -f /app/package.json || echo "Warning: package.json not found" && \
    test -f /opt/unm/app.js || (echo "Error: UnblockNeteaseMusic app.js not found" && exit 1)

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:3010/health || exit 1

# 暴露端口
EXPOSE 3010

# 设置工作目录
WORKDIR /

# 启动命令
CMD ["/usr/local/bin/docker-entrypoint.sh"]