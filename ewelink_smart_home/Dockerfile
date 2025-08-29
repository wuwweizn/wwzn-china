# 使用 Node.js 18 Alpine 作为基础镜像
FROM node:18-alpine

# 设置工作目录
WORKDIR /app

# 拷贝源码到容器
COPY . /app

# 安装依赖
RUN npm install --production

# 暴露端口
EXPOSE 3000

# 启动命令
CMD ["npm", "start"]
