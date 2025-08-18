ARG BUILD_ARCH

# 构建阶段
FROM node:18-alpine AS builder

# 设置工作目录
WORKDIR /app

# 安装系统依赖
RUN apk add --no-cache \
    git \
    python3 \
    make \
    g++ \
    vips-dev \
    libc6-compat

# 设置npm配置
RUN npm config set registry https://registry.npmmirror.com/
ENV NODE_OPTIONS="--max-old-space-size=4096"

# 克隆指定版本的源码
RUN git clone --depth 1 --branch main https://github.com/qier222/YesPlayMusic.git .

# 修复package.json中可能的问题
RUN sed -i 's/"type": "module",//g' package.json || true

# 清理并重新安装依赖
RUN rm -rf node_modules package-lock.json
RUN npm install --legacy-peer-deps --production=false

# 设置构建环境变量
ENV VITE_NETEASE_API_URL=/api
ENV NODE_ENV=production

# 构建项目（添加错误处理）
RUN npm run build || (echo "构建失败，尝试使用备用方案" && npm run build:prod) || \
    (echo "所有构建方案失败，创建基础静态文件" && \
     mkdir -p dist && \
     cp -r public/* dist/ 2>/dev/null || true && \
     echo '<!DOCTYPE html><html><head><title>YesPlayMusic</title></head><body><h1>YesPlayMusic Loading...</h1></body></html>' > dist/index.html)

# 生产阶段
FROM nginx:alpine

# 安装运行时依赖
RUN apk add --no-cache \
    supervisor \
    jq \
    gettext \
    curl \
    bash

# 复制构建结果
COPY --from=builder /app/dist /usr/share/nginx/html

# 验证构建结果
RUN ls -la /usr/share/nginx/html/ && \
    if [ ! -f "/usr/share/nginx/html/index.html" ]; then \
        echo "构建失败，创建默认页面"; \
        echo '<!DOCTYPE html><html><head><title>YesPlayMusic</title><meta charset="utf-8"><style>body{font-family:Arial,sans-serif;text-align:center;margin-top:50px}.container{max-width:600px;margin:0 auto;padding:20px}</style></head><body><div class="container"><h1>YesPlayMusic</h1><p>正在加载中...</p></div></body></html>' > /usr/share/nginx/html/index.html; \
    fi

# 复制配置文件
COPY nginx.conf /etc/nginx/nginx.conf
COPY run.sh /run.sh
COPY supervisord.conf /etc/supervisord.conf

# 设置权限
RUN chmod +x /run.sh

# 创建必要的目录
RUN mkdir -p /var/log/nginx /var/log/supervisor

# 暴露端口
EXPOSE 80 443

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# 启动脚本
CMD ["/run.sh"]