ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.19
FROM ${BUILD_FROM}

# 设置工作目录
WORKDIR /

# 安装必要的依赖
RUN apk add --no-cache \
    nginx \
    nodejs \
    npm \
    git \
    bash \
    sed \
    supervisor \
    && rm -rf /var/cache/apk/*

# 克隆 Solara 项目
RUN git clone https://github.com/akudamatata/Solara.git /tmp/solara && \
    mkdir -p /var/www/html && \
    cp -r /tmp/solara/* /var/www/html/ && \
    rm -rf /tmp/solara

# 创建必要的目录
RUN mkdir -p /run/nginx /var/log/nginx /data /config /app/api

# 复制 API 代理服务
COPY api-proxy.js /app/api/proxy.js

# 复制配置文件
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisord.conf
COPY run.sh /usr/bin/run.sh

# 设置执行权限
RUN chmod a+x /usr/bin/run.sh

# 暴露端口
EXPOSE 3100 3101

# 启动脚本
CMD ["/usr/bin/run.sh"]