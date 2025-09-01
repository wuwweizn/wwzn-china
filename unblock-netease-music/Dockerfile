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

# 创建简单的启动脚本
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'echo "[INFO] 启动 UnblockNeteaseMusic..."' >> /start.sh && \
    echo 'echo "[INFO] 端口: ${UNM_PORT:-8080}"' >> /start.sh && \
    echo 'echo "[INFO] 地址: ${UNM_HOST:-0.0.0.0}"' >> /start.sh && \
    echo 'echo "[INFO] 音源: ${UNM_SOURCE_ORDER:-kuwo kugou migu}"' >> /start.sh && \
    echo 'cd /app' >> /start.sh && \
    echo 'ARGS="-p ${UNM_PORT:-8080} -a ${UNM_HOST:-0.0.0.0}"' >> /start.sh && \
    echo 'if [ -n "${UNM_SOURCE_ORDER}" ]; then' >> /start.sh && \
    echo '  for src in ${UNM_SOURCE_ORDER:-kuwo kugou migu}; do' >> /start.sh && \
    echo '    ARGS="$ARGS -o $src"' >> /start.sh && \
    echo '  done' >> /start.sh && \
    echo 'else' >> /start.sh && \
    echo '  ARGS="$ARGS -o kuwo -o kugou -o migu"' >> /start.sh && \
    echo 'fi' >> /start.sh && \
    echo 'echo "[INFO] 启动参数: node app.js $ARGS"' >> /start.sh && \
    echo 'exec node app.js $ARGS' >> /start.sh && \
    chmod +x /start.sh

# 启动命令
CMD ["/start.sh"]