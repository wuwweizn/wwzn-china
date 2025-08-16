# 直接使用官方 AList 镜像
FROM xhofe/alist:v3.41.0

# 切换到 root 用户
USER root

# 安装必要的依赖
RUN apk add --no-cache \
    bash \
    tini \
    tzdata \
    ca-certificates

# 创建数据目录
RUN mkdir -p /data

# 复制启动脚本
COPY run.sh /usr/bin/run.sh
RUN chmod +x /usr/bin/run.sh

# 设置环境变量
ENV PUID=0
ENV PGID=0

# 暴露端口
EXPOSE 5244

# 使用 tini 作为入口点
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/bin/run.sh"]