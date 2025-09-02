# 使用Home Assistant基础镜像
ARG BUILD_FROM
FROM $BUILD_FROM

# 安装Node.js和必要工具
RUN apk add --no-cache \
    nodejs \
    npm \
    curl \
    && rm -rf /var/cache/apk/*

# 设置工作目录
WORKDIR /app

# 全局安装 UnblockNeteaseMusic/server
RUN npm install -g @unblockneteasemusic/server@latest

# 复制启动脚本
COPY run.sh /
RUN chmod a+x /run.sh

# 设置环境变量
ENV NODE_ENV=production

# 暴露端口
EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# 启动命令
CMD ["/run.sh"]