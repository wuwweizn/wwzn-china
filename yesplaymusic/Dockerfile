# 构建阶段：使用 Node 构建 YesPlayMusic
FROM node:18 AS builder

RUN apt-get update && apt-get install -y git

RUN git clone https://github.com/stark81/my_yesplaymusic.git /app

WORKDIR /app

# 设置构建时环境变量，使 API URL 为 /api（用于代理）
ENV VUE_APP_NETEASE_API_URL=/api

RUN npm install && npm run build

# 运行阶段：使用 Nginx 服务构建产物
FROM nginx:alpine

# 安装 jq 用于读取 HA options.json
RUN apk add --no-cache jq

# 复制构建产物
COPY --from=builder /app/dist /usr/share/nginx/html

# 复制 Nginx 配置模板和 entrypoint 脚本
COPY nginx.conf.template /etc/nginx/conf.d/default.conf.template
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# 暴露端口
EXPOSE 80

# 使用 entrypoint 处理配置并启动 Nginx
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]