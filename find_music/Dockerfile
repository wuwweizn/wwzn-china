FROM node:20-alpine

WORKDIR /app

# 复制项目文件
COPY . .

# 安装依赖
RUN npm install

# 构建前端
RUN npm run build

# 暴露端口
EXPOSE 3000

# 启动
CMD ["npm", "start"]
