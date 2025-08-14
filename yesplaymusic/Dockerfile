ARG BUILD_FROM=alpine:3.21.3
FROM $BUILD_FROM

# 安装系统依赖
RUN apk add --no-cache \
    curl \
    bash \
    jq \
    nginx \
    supervisor \
    nodejs \
    npm \
    git

# 安装bashio
RUN curl -J -L -o /tmp/bashio.tar.gz \
        "https://github.com/hassio-addons/bashio/archive/v0.16.2.tar.gz" \
    && mkdir /tmp/bashio \
    && tar zxvf /tmp/bashio.tar.gz --strip 1 -C /tmp/bashio \
    && mv /tmp/bashio/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    && rm -rf /tmp/bashio.tar.gz /tmp/bashio

# 创建必要的目录
RUN mkdir -p /var/www/html \
    /var/log/nginx \
    /var/lib/nginx/tmp \
    /run/nginx \
    /var/log/supervisor \
    /etc/supervisor/conf.d \
    /app

# 设置工作目录
WORKDIR /app

# 克隆并构建YesPlayMusic
RUN git clone --depth 1 https://github.com/qier222/YesPlayMusic.git . && \
    rm -rf .git && \
    npm install -g yarn && \
    echo "VUE_APP_NETEASE_API_URL=/api" > .env && \
    yarn install --frozen-lockfile --ignore-engines && \
    yarn build && \
    cp -r dist/* /var/www/html/ && \
    rm -rf node_modules src public .git* yarn.lock package*.json

# 复制配置文件和HTML文件
COPY rootfs /
COPY index.html /var/www/html/

# 设置权限
RUN chmod +x /usr/local/bin/run.sh /usr/local/bin/setup_nginx.sh && \
    chown -R nginx:nginx /var/www/html /var/log/nginx /var/lib/nginx /run/nginx

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# 暴露端口
EXPOSE 80

# 标签
LABEL \
    io.hass.name="YesPlayMusic" \
    io.hass.description="高颜值的第三方网易云播放器" \
    io.hass.type="addon" \
    io.hass.version="1.0.3"

# 启动命令
CMD ["/usr/local/bin/run.sh"]