ARG BUILD_FROM=ghcr.io/hassio-addons/base:latest
FROM node:20-alpine AS builder

# 克隆 OuonnkiTV 源码并构建
RUN apk add --no-cache git && \
    git clone --depth=1 https://github.com/Ouonnki/OuonnkiTV /build

WORKDIR /build

# 安装 pnpm 并构建
RUN npm install -g pnpm && \
    pnpm install && \
    pnpm build

# ---- 运行阶段：使用 nginx 托管静态文件 ----
FROM nginx:alpine

LABEL \
  io.hass.name="OuonnkiTV" \
  io.hass.description="一键搭建个人影视站，基于LibreTV修改" \
  io.hass.arch="${BUILD_ARCH}" \
  io.hass.type="addon" \
  maintainer="wuwweizn"

# 将构建产物复制到 nginx 目录
COPY --from=builder /build/dist /usr/share/nginx/html

# 使用启动脚本来注入 HA 的 options 环境变量（运行时）
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 80

CMD ["/run.sh"]
