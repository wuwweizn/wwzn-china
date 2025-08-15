FROM alpine:latest

# 安装必要的系统包
RUN apk add --no-cache \
        curl \
        bash \
        jq \
        nginx \
        supervisor \
        nodejs \
        npm \
        git \
        python3 \
        make \
        g++

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

# 安装yarn
RUN npm install -g yarn

# 下载并构建YesPlayMusic
RUN echo "Downloading YesPlayMusic..." && \
    git clone --depth 1 https://github.com/qier222/YesPlayMusic.git . && \
    rm -rf .git

# 创建环境配置
RUN echo 'VUE_APP_NETEASE_API_URL=/api' > .env

# 安装依赖并构建
RUN echo "Installing dependencies..." && \
    yarn install --frozen-lockfile --ignore-engines --network-timeout 100000 && \
    echo "Building application..." && \
    yarn build && \
    echo "Copying built files..." && \
    cp -r dist/* /var/www/html/ && \
    echo "Cleaning up..." && \
    rm -rf node_modules src public .git* yarn.lock package*.json && \
    cd / && rm -rf /app

# 验证构建结果并设置备用页面
RUN ls -la /var/www/html/ && \
    if [ ! -f "/var/www/html/index.html" ] || [ ! -d "/var/www/html/assets" ]; then \
        echo "Build incomplete, using fallback page..." && \
        rm -f /var/www/html/index.html; \
    fi

# 复制配置文件和备用页面
COPY rootfs /
COPY fallback.html /var/www/html/fallback.html

# 设置启动页面逻辑
RUN if [ ! -f "/var/www/html/index.html" ]; then \
        echo "Using fallback as main page" && \
        cp /var/www/html/fallback.html /var/www/html/index.html; \
    fi

# 设置权限
RUN chmod +x /usr/local/bin/run.sh /usr/local/bin/setup_nginx.sh && \
    chown -R nginx:nginx /var/www/html /var/log/nginx /var/lib/nginx /run/nginx

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# 暴露端口
EXPOSE 80

# 环境变量
ENV NETEASE_API_URL=https://music-api.hankqin.com
ENV SSL=false
ENV CERTFILE=fullchain.pem
ENV KEYFILE=privkey.pem
ENV CUSTOM_TITLE=YesPlayMusic
ENV VUE_APP_NETEASE_API_URL=/api

# 标签
LABEL \
    io.hass.name="YesPlayMusic" \
    io.hass.description="高颜值的第三方网易云播放器" \
    io.hass.type="addon" \
    io.hass.version="1.0.4"

# 启动命令
CMD ["/usr/local/bin/run.sh"]