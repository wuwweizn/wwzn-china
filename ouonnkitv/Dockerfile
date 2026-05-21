# 构建阶段：固定用 amd64，避免 lightningcss 等原生模块在 armv7 上无预编译二进制的问题
FROM --platform=linux/amd64 node:20-alpine AS builder

# 克隆 OuonnkiTV 源码并构建
RUN apk add --no-cache git && \
    git clone --depth=1 https://github.com/Ouonnki/OuonnkiTV /build

WORKDIR /build

# 安装 pnpm 并构建（始终在 amd64 上执行，输出纯静态文件）
RUN npm install -g pnpm && \
    pnpm install && \
    pnpm build

# ---- 运行阶段：跟随目标架构，使用 nginx 托管静态文件 ----
FROM nginx:alpine

ARG BUILD_ARCH=amd64

LABEL \
  io.hass.name="OuonnkiTV" \
  io.hass.description="一键搭建个人影视站，基于LibreTV修改" \
  io.hass.arch="${BUILD_ARCH}" \
  io.hass.type="addon" \
  maintainer="wuwweizn"

# 将构建产物复制到 nginx 目录
COPY --from=builder /build/dist /usr/share/nginx/html

# 启动脚本：读取 HA options.json 并生成 runtime-config.json
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 80

CMD ["/run.sh"]