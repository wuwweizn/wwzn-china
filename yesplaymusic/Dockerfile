FROM node:18-bullseye-slim AS build
WORKDIR /app

# 安装构建依赖 + yarn
RUN apt-get update && apt-get install -y \
  git \
  python3 \
  make \
  g++ \
  && npm install -g yarn \
  && rm -rf /var/lib/apt/lists/*

# 克隆源码
RUN git clone https://github.com/qier222/YesPlayMusic.git .

# 用 yarn 安装依赖
RUN yarn install --network-timeout 600000

# 构建前端
RUN yarn build

# ---------------- runtime ----------------
FROM nginx:alpine
WORKDIR /app

COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf.template /etc/nginx/templates/nginx.conf.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV API_URL=http://47.121.211.116:3001

EXPOSE 8080
CMD ["/entrypoint.sh"]
