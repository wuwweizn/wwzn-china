# 基于官方 Node.js Alpine 镜像，轻量且安全
FROM node:18-alpine

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV NODE_ENV=production

# 安装必要的系统依赖
RUN apk add --no-cache \
    git \
    && rm -rf /var/cache/apk/*

# 克隆最新的 UnblockNeteaseMusic 源码
RUN git clone https://github.com/nondanee/UnblockNeteaseMusic.git /app

# 安装 Node.js 依赖
RUN npm install --only=production && npm cache clean --force

# 创建非root用户
RUN addgroup -g 1000 unm && \
    adduser -D -s /bin/sh -u 1000 -G unm unm

# 更改文件所有者
RUN chown -R unm:unm /app

# 切换到非root用户
USER unm

# 暴露端口
EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

# 启动命令
CMD ["node", "app.js"]