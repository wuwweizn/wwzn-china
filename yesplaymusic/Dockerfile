# 构建阶段：使用 Node 构建 YesPlayMusic
FROM node:18 AS builder

# 安装 git 和其他必要工具
RUN apt-get update && apt-get install -y git && apt-get clean

# 克隆 YesPlayMusic 仓库
RUN git clone https://github.com/stark81/my_yesplaymusic.git /app || { echo "无法克隆仓库，请检查 URL 或网络"; exit 1; }

WORKDIR /app

# 调试：打印 Node.js 和 npm 版本
RUN echo "Node.js 版本:" && node --version && echo "npm 版本:" && npm --version

# 调试：检查 package.json 是否存在
RUN if [ ! -f "package.json" ]; then echo "package.json 未找到！"; exit 1; fi

# 设置 npm 镜像（加速国内网络）
RUN npm config set registry https://registry.npmmirror.com

# 清理 npm 缓存并安装依赖
RUN npm cache clean --force && npm install --verbose --network-timeout 600000 || { echo "npm install 失败，请检查日志"; exit 1; }

# 设置环境变量，使 API URL 为 /api（用于代理）
ENV VUE_APP_NETEASE_API_URL=/api

# 构建应用
RUN npm run build || { echo "npm run build 失败，请检查日志"; exit 1; }

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