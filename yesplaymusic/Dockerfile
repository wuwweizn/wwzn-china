# =========================
# 构建阶段
# =========================
FROM node:18-alpine AS build

WORKDIR /app

# 安装必要工具
RUN apk add --no-cache bash git curl python3 make g++

# 克隆源码
RUN git clone https://github.com/qier222/YesPlayMusic.git /app

# 使用 npm 镜像源
RUN npm config set registry https://registry.npmmirror.com

# 安装所有依赖（含 devDependencies）
RUN npm install --legacy-peer-deps

# 构建前端
RUN npm run build

# =========================
# 运行阶段
# =========================
FROM node:18-alpine

WORKDIR /app

# 复制构建产物
COPY --from=build /app /app

# 复制运行脚本
COPY run.sh /run.sh
RUN chmod +x /run.sh

# 暴露端口
EXPOSE 3000

CMD ["/run.sh"]
