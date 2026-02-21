# 基于官方 xiaomusic 镜像构建
ARG BUILD_FROM
FROM ${BUILD_FROM}

# 复制启动脚本
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
