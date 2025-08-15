# 使用 Node.js 18 轻量版
FROM node:18-alpine

# 工作目录
WORKDIR /app

# 安装必要工具
RUN apk add --no-cache bash git curl

# 克隆 YesPlayMusic 仓库
RUN git clone https://github.com/qier222/YesPlayMusic.git /app

# 设置 npm 镜像源并安装依赖
RUN npm config set registry https://registry.npmmirror.com && npm install --production

# 复制运行脚本
COPY run.sh /run.sh
RUN chmod +x /run.sh

# 暴露端口
EXPOSE 3000

# 启动脚本
CMD ["/run.sh"]
