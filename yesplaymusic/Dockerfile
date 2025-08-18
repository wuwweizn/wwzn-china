ARG BUILD_ARCH

FROM node:18-alpine AS builder

# 安装构建依赖
RUN apk add --no-cache git python3 make g++

# 克隆YesPlayMusic源码
WORKDIR /app
RUN git clone https://github.com/qier222/YesPlayMusic.git .

# 安装依赖并构建
RUN npm install --legacy-peer-deps
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