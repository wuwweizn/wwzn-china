# 构建阶段：使用 Node 构建 YesPlayMusic
FROM node:16 AS builder

# 设置 Debian 归档镜像（因为 Buster 已停止标准支持）
RUN echo "deb http://archive.debian.org/debian buster main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security buster/updates main" >> /etc/apt/sources.list

# 调试：检查软件源配置
RUN cat /etc/apt/sources.list

# 调试：测试网络连接
RUN ping -c 3 archive.debian.org || echo "无法 ping archive.debian.org" && \
    ping -c 3 8.8.8.8 || echo "无法 ping 8.8.8.8"

# 更新包索引并安装常见构建工具
RUN apt-get update --allow-insecure-repositories || { echo "apt-get update 失败，请检查网络或软件源"; exit 1; } && \
    apt-get install -y --no-install-recommends git python3 make g++ && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* || { echo "apt-get install 或清理失败"; exit 1; }

# 调试：检查安装的工具版本
RUN git --version && python3 --version && make --version && g++ --version

# 克隆 YesPlayMusic 仓库
RUN git clone https://github.com/stark81/my_yesplaymusic.git /app || { echo "无法克隆仓库，请检查 URL 或网络"; exit 1; }

WORKDIR /app

# 调试：打印 Node.js、npm 版本及目录内容
RUN echo "Node.js 版本:" && node --version && \
    echo "npm 版本:" && npm --version && \
    echo "当前目录内容:" && ls -la

# 调试：检查 package.json 是否存在
RUN if [ ! -f "package.json" ]; then echo "package.json 未找到！"; exit 1; fi

# 设置 npm 镜像（加速国内网络）
RUN npm config set registry https://registry.npmmirror.com

# 清理 npm 缓存并优先使用 npm ci
RUN npm cache clean --force && \
    if [ -f "package-lock.json" ]; then \
      npm ci --verbose --network-timeout 600000 || { echo "npm ci 失败，请检查日志"; exit 1; }; \
    else \
      npm install --verbose --network-timeout 600000 || { echo "npm install 失败，请检查日志"; exit 1; }; \
    fi

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