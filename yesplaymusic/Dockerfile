ARG BUILD_FROM=node:18-alpine
FROM $BUILD_FROM

# 环境变量
ENV NODE_ENV=production
ENV VUE_APP_NETEASE_API_URL=/api

# 安装系统依赖和bashio
RUN apk add --no-cache \
    curl \
    bash \
    jq \
    nginx \
    supervisor \
    && curl -J -L -o /tmp/bashio.tar.gz \
        "https://github.com/hassio-addons/bashio/archive/v0.16.2.tar.gz" \
    && mkdir /tmp/bashio \
    && tar zxvf \
        /tmp/bashio.tar.gz \
        --strip 1 -C /tmp/bashio \
    && mv /tmp/bashio/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    && rm -rf /tmp/bashio.tar.gz /tmp/bashio

# 创建应用目录
WORKDIR /app

# 下载预构建的YesPlayMusic
RUN curl -L -o yesplaymusic.tar.gz \
    "https://github.com/qier222/YesPlayMusic/releases/download/v0.4.7/YesPlayMusic-linux-x64-0.4.7.tar.gz" \
    2>/dev/null || echo "Using alternative download method"

# 如果预构建版本不可用，则从源码构建
RUN if [ ! -f yesplaymusic.tar.gz ]; then \
        echo "Downloading source code..." && \
        curl -L -o source.tar.gz \
        "https://github.com/qier222/YesPlayMusic/archive/refs/tags/v0.4.7.tar.gz" && \
        tar -xzf source.tar.gz --strip-components=1 && \
        rm source.tar.gz && \
        echo "VUE_APP_NETEASE_API_URL=/api" > .env && \
        npm install -g yarn && \
        yarn install --frozen-lockfile && \
        yarn build && \
        mkdir -p /var/www/html && \
        cp -r dist/* /var/www/html/ && \
        rm -rf node_modules src public; \
    else \
        echo "Using pre-built version..." && \
        mkdir -p /var/www/html && \
        echo "Pre-built version extraction skipped - will use embedded files"; \
    fi

# 或者直接使用在线版本的静态文件构建
RUN mkdir -p /var/www/html && \
    echo '<!DOCTYPE html>
<html>
<head>
    <title>YesPlayMusic</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <style>
        body, html { margin: 0; padding: 0; height: 100%; overflow: hidden; }
        #app { width: 100%; height: 100vh; border: none; }
    </style>
</head>
<body>
    <div id="loading" style="display: flex; justify-content: center; align-items: center; height: 100vh; font-family: Arial;">
        <div>
            <h2>🎵 YesPlayMusic Loading...</h2>
            <p>正在初始化音乐播放器...</p>
        </div>
    </div>
    <iframe id="app" src="https://music.qier222.com" style="display: none;" onload="document.getElementById(\"loading\").style.display=\"none\"; this.style.display=\"block\";"></iframe>
</body>
</html>' > /var/www/html/index.html

# 创建必要的目录
RUN mkdir -p /var/log/nginx \
    /var/lib/nginx/tmp \
    /run/nginx \
    /var/log/supervisor \
    /etc/supervisor/conf.d

# 复制配置文件
COPY rootfs /

# 设置权限
RUN chmod +x /usr/local/bin/run.sh /usr/local/bin/setup_nginx.sh && \
    chown -R nginx:nginx /var/www/html /var/log/nginx /var/lib/nginx /run/nginx

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# 暴露端口
EXPOSE 80

# 标签
LABEL \
    io.hass.name="YesPlayMusic" \
    io.hass.description="高颜值的第三方网易云播放器" \
    io.hass.type="addon" \
    io.hass.version="1.0.3" \
    maintainer="wuwweizn"

# 启动命令
CMD ["/usr/local/bin/run.sh"]