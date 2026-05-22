# ============================================================
# 构建阶段：固定 amd64，避免 lightningcss 等原生模块在 armv7
# 无预编译二进制时的编译失败问题。
# 输出为纯静态文件，无架构依赖。
# ============================================================
FROM --platform=linux/amd64 node:20-alpine AS builder

# OuonnkiTV 所有环境变量均在【构建时】注入（Vite import.meta.env）
# 通过 ARG → ENV 传递，pnpm build 时会打包进静态文件
ARG OKI_INITIAL_VIDEO_SOURCES=""
ARG OKI_TMDB_API_TOKEN=""
ARG OKI_TMDB_API_BASE_URL="https://api.tmdb.org/3"
ARG OKI_TMDB_IMAGE_BASE_URL="https://image.tmdb.org/t/p/"
ARG OKI_ACCESS_PASSWORD=""
ARG OKI_DISABLE_ANALYTICS="true"
ARG OKI_INITIAL_CONFIG=""

ENV OKI_INITIAL_VIDEO_SOURCES=${OKI_INITIAL_VIDEO_SOURCES}
ENV OKI_TMDB_API_TOKEN=${OKI_TMDB_API_TOKEN}
ENV OKI_TMDB_API_BASE_URL=${OKI_TMDB_API_BASE_URL}
ENV OKI_TMDB_IMAGE_BASE_URL=${OKI_TMDB_IMAGE_BASE_URL}
ENV OKI_ACCESS_PASSWORD=${OKI_ACCESS_PASSWORD}
ENV OKI_DISABLE_ANALYTICS=${OKI_DISABLE_ANALYTICS}
ENV OKI_INITIAL_CONFIG=${OKI_INITIAL_CONFIG}

RUN apk add --no-cache git && \
    git clone --depth=1 https://github.com/Ouonnki/OuonnkiTV /build

WORKDIR /build

RUN npm install -g pnpm && \
    pnpm install && \
    pnpm build

# ============================================================
# 运行阶段：跟随目标架构，nginx 托管静态文件
# ============================================================
FROM nginx:alpine

ARG BUILD_ARCH=amd64

LABEL \
  io.hass.name="OuonnkiTV" \
  io.hass.description="一键搭建个人影视站，支持TMDB智能模式，基于LibreTV修改" \
  io.hass.arch="${BUILD_ARCH}" \
  io.hass.type="addon" \
  maintainer="wuwweizn"

# 覆盖 nginx 默认配置，监听 17380 端口
RUN printf 'server {\n\
    listen 17380;\n\
    root /usr/share/nginx/html;\n\
    index index.html;\n\
    location / {\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
}\n' > /etc/nginx/conf.d/default.conf

COPY --from=builder /build/dist /usr/share/nginx/html

EXPOSE 17380

CMD ["nginx", "-g", "daemon off;"]