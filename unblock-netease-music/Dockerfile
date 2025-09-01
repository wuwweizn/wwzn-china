# 基于官方 Node.js Alpine 镜像
FROM node:18-alpine

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV NODE_ENV=production
ENV DEBUG=""
ENV ENABLE_LOCAL_VIP=1

# 安装必要的系统依赖和工具
RUN apk add --no-cache \
    git \
    wget \
    curl \
    ca-certificates \
    tzdata \
    && rm -rf /var/cache/apk/*

# 设置时区为上海
ENV TZ=Asia/Shanghai

# 克隆 UnblockNeteaseMusic 源码并检出最新稳定版本
RUN git clone --depth 1 https://github.com/nondanee/UnblockNeteaseMusic.git /tmp/unm && \
    cp -r /tmp/unm/* /app/ && \
    rm -rf /tmp/unm

# 安装依赖
RUN npm install --only=production && \
    npm cache clean --force

# 创建必要的目录结构
RUN mkdir -p /app/cache /app/logs

# 更改文件所有者到node用户
RUN chown -R node:node /app

# 切换到node用户
USER node

# 暴露端口
EXPOSE 8080

# 添加更详细的健康检查
HEALTHCHECK --interval=30s --timeout=15s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8080/ || wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

# 启动命令 - 使用修正的环境变量名称
CMD ["sh", "-c", "echo '[INFO] 启动 UnblockNeteaseMusic...' && echo '[INFO] 端口:' ${UNM_PORT:-8080} && echo '[INFO] 地址:' ${UNM_HOST:-0.0.0.0} && echo '[INFO] 音源:' ${UNM_SOURCE_ORDER:-kuwo kugou migu} && cd /app && exec node app.js -p ${UNM_PORT:-8080} -a ${UNM_HOST:-0.0.0.0} -o ${UNM_SOURCE_ORDER:-kuwo kugou migu}"]