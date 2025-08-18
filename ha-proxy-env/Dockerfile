ARG BUILD_FROM=ghcr.io/hassio-addons/base:14.3.2
FROM $BUILD_FROM

# 安装 nginx
RUN apk add --no-cache nginx

# 拷贝前端页面
COPY webui /usr/share/nginx/html

# 拷贝启动脚本
COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
