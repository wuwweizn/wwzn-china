ARG BUILD_ARCH

FROM node:18-alpine AS builder

# 安装构建依赖
RUN apk add --no-cache git python3 make g++ vips-dev

# 设置npm配置
RUN npm config set registry https://registry.npmmirror.com/
RUN npm config set legacy-peer-deps true

# 克隆YesPlayMusic源码
WORKDIR /app
RUN git clone --depth 1 https://github.com/qier222/YesPlayMusic.git .

# 设置Node.js内存限制和环境变量
ENV NODE_OPTIONS="--max-old-space-size=4096"
ENV NODE_ENV=production
ENV VITE_NETEASE_API_URL=/api

# 清理package-lock.json避免依赖冲突
RUN rm -f package-lock.json

# 安装依赖
RUN npm install --legacy-peer-deps --no-audit --no-fund

# 构建项目
RUN npm run build

# 生产阶段
FROM nginx:alpine

# 安装supervisor用于进程管理
RUN apk add --no-cache supervisor

# 复制构建好的文件
COPY --from=builder /app/dist /usr/share/nginx/html

# 复制nginx配置
COPY nginx.conf /etc/nginx/nginx.conf

# 复制启动脚本
COPY run.sh /run.sh
RUN chmod +x /run.sh

# 复制supervisor配置
COPY supervisord.conf /etc/supervisord.conf

# 暴露端口
EXPOSE 80 443

# 启动
CMD ["/run.sh"]