FROM node:18-alpine AS build
WORKDIR /app
RUN apk add --no-cache git
RUN git clone https://github.com/qier222/YesPlayMusic.git .
RUN npm install --legacy-peer-deps
RUN npm run build

FROM nginx:alpine
WORKDIR /app

# 拷贝静态文件
COPY --from=build /app/dist /usr/share/nginx/html

# 拷贝模板和启动脚本
COPY nginx.conf.template /etc/nginx/templates/nginx.conf.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV API_URL=http://47.121.211.116:3001

EXPOSE 8080
CMD ["/entrypoint.sh"]
