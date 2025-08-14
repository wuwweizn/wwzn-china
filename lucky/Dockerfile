# 使用官方 Alpine 或 Debian 作为基础镜像
FROM alpine:3.18

# 作者信息
LABEL maintainer="Your Name <you@example.com>"

# 安装必要的软件包（根据 lucky 需求调整）
RUN apk add --no-cache \
    bash \
    curl \
    git \
    nodejs \
    npm \
    python3 \
    py3-pip

# 设置工作目录
WORKDIR /app

# 复制你的 lucky 项目到镜像中
COPY . /app

# 安装项目依赖（如果是 Node.js 项目）
RUN npm install --production

# 暴露端口（根据 lucky 项目实际端口修改）
EXPOSE 7478

# 设置默认命令
CMD ["node", "index.js"]
