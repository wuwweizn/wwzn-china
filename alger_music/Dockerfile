FROM node:18-alpine

# 设置工作目录
WORKDIR /app

# 拷贝源码
COPY . /app

# 安装依赖
RUN npm install --production

# 确保运行脚本有权限
RUN chmod +x /app/run.sh

# 暴露端口
EXPOSE 3000

CMD [ "/app/run.sh" ]
