# 使用Home Assistant基础镜像
ARG BUILD_FROM
FROM $BUILD_FROM

# 安装必要的软件包
RUN apk add --no-cache \
    nodejs \
    npm \
    git \
    && rm -rf /var/cache/apk/*

# 设置工作目录
WORKDIR /app

# 克隆UnblockNeteaseMusic源码
RUN git clone --depth 1 https://github.com/nondanee/UnblockNeteaseMusic.git /app

# 安装依赖
RUN npm install --only=production && npm cache clean --force

# 复制启动脚本
COPY run.sh /
RUN chmod a+x /run.sh

# 设置环境变量
ENV NODE_ENV=production
ENV ENABLE_LOCAL_VIP=1

# 暴露端口
EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# 启动命令
CMD ["/run.sh"]