FROM node:18 AS build
WORKDIR /app

# 安装构建依赖
RUN apt-get update && apt-get install -y git python3 make g++ \
  && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/qier222/YesPlayMusic.git .
RUN npm install --legacy-peer-deps
RUN npm run build

FROM nginx:alpine
WORKDIR /app
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf.template /etc/nginx/templates/nginx.conf.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENV API_URL=http://47.121.211.116:3001
EXPOSE 8080
CMD ["/entrypoint.sh"]
