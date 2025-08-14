ARG BUILD_FROM=node:18-alpine
FROM $BUILD_FROM

# 设置工作目录
WORKDIR /app

# 安装必要的系统包
RUN apk add --no-cache \
    git \
    nginx \
    supervisor \
    curl \
    bash \
    jq

# 克隆YesPlayMusic仓库
RUN git clone --recursive --depth 1 https://github.com/qier222/YesPlayMusic.git /tmp/yesplaymusic

# 复制源码到工作目录
COPY --from=0 /tmp/yesplaymusic /app/

# 安装yarn（如果没有）
RUN npm install -g yarn

# 安装项目依赖
RUN yarn install --frozen-lockfile --non-interactive

# 复制环境配置文件
COPY rootfs/etc/yesplaymusic/.env /app/.env

# 构建项目
RUN yarn build

# 配置Nginx
RUN mkdir -p /var/log/nginx && \
    mkdir -p /var/lib/nginx/tmp && \
    mkdir -p /run/nginx

# 复制配置文件
COPY rootfs/etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY rootfs/etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY rootfs/usr/local/bin/run.sh /usr/local/bin/run.sh
COPY rootfs/usr/local/bin/setup_nginx.sh /usr/local/bin/setup_nginx.sh

# 设置执行权限
RUN chmod +x /usr/local/bin/run.sh /usr/local/bin/setup_nginx.sh

# 复制构建好的文件到nginx目录
RUN cp -r /app/dist/* /var/www/html/ || mkdir -p /var/www/html && cp -r /app/dist/* /var/www/html/

# 设置正确的文件权限
RUN chown -R nginx:nginx /var/www/html && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /var/lib/nginx

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# 暴露端口
EXPOSE 80

# 启动脚本
CMD ["/usr/local/bin/run.sh"]