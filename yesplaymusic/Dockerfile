FROM alpine:latest

# 安装必要的系统包
RUN apk add --no-cache \
        curl \
        bash \
        jq \
        nginx \
        supervisor

# 创建必要的目录
RUN mkdir -p /var/www/html \
    /var/log/nginx \
    /var/lib/nginx/tmp \
    /run/nginx \
    /var/log/supervisor \
    /etc/supervisor/conf.d

# 复制配置文件
COPY rootfs /

# 复制HTML文件
COPY index.html /var/www/html/

# 设置权限
RUN chmod +x /usr/local/bin/run.sh /usr/local/bin/setup_nginx.sh && \
    chown -R nginx:nginx /var/www/html /var/log/nginx /var/lib/nginx /run/nginx

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# 暴露端口
EXPOSE 80

# 环境变量
ENV NETEASE_API_URL=https://music-api.hankqin.com
ENV SSL=false
ENV CERTFILE=fullchain.pem
ENV KEYFILE=privkey.pem
ENV CUSTOM_TITLE=YesPlayMusic

# 标签
LABEL \
    io.hass.name="YesPlayMusic" \
    io.hass.description="高颜值的第三方网易云播放器" \
    io.hass.type="addon" \
    io.hass.version="1.0.3"

# 启动命令
CMD ["/usr/local/bin/run.sh"]