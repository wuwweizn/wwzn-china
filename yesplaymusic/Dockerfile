FROM node:18-bullseye-slim AS build
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
  git \
  python3 \
  make \
  g++ \
  && rm -rf /var/lib/apt/lists/*

# 克隆源码
RUN git clone https://github.com/qier222/YesPlayMusic.git .

# 用 yarn 安装依赖
RUN corepack enable && yarn install --frozen-lockfile

# 构建前端
RUN yarn build

# ---------------- runtime ----------------
FROM nginx:alpine
WORKDIR /app

# 拷贝构建产物
COPY --from=build /app/dist /usr/share/nginx/html

# 拷贝模板和启动脚本
COPY nginx.conf.template /etc/nginx/templates/nginx.conf.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV API_URL=http://47.121.211.116:3001

EXPOSE 8080
CMD ["/entrypoint.sh"]
