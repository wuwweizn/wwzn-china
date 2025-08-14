# 使用官方 Node.js 20 Alpine 版本作为基础镜像
FROM node:20-alpine

# 作者信息
LABEL maintainer="Your Name <you@example.com>"

# 设置工作目录
WORKDIR /app

# 先复制 package.json 和 package-lock.json，避免每次构建都重新安装依赖
COPY package*.json ./

# 安装依赖（仅生产环境依赖）
RUN npm install --production

# 复制剩余项目文件
COPY . .

# 暴露端口（根据 lucky 实际端口修改，如果是 7478 就保持）
EXPOSE 7478

# 启动应用
CMD ["node", "index.js"]
