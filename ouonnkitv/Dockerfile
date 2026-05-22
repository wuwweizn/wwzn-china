# ============================================================
# 构建阶段：固定 amd64，避免 lightningcss 等原生模块在 armv7
# 无预编译二进制时的编译失败问题。
# 使用占位符构建，运行时由 run.sh 替换真实值。
# ============================================================
FROM --platform=linux/amd64 node:20-alpine AS builder

# 用占位符构建，run.sh 启动时用 sed 替换进 JS bundle
ENV OKI_INITIAL_VIDEO_SOURCES="__OKI_INITIAL_VIDEO_SOURCES__"
ENV OKI_TMDB_API_TOKEN="__OKI_TMDB_API_TOKEN__"
ENV OKI_TMDB_API_BASE_URL="__OKI_TMDB_API_BASE_URL__"
ENV OKI_TMDB_IMAGE_BASE_URL="__OKI_TMDB_IMAGE_BASE_URL__"
ENV OKI_ACCESS_PASSWORD="__OKI_ACCESS_PASSWORD__"
ENV OKI_DISABLE_ANALYTICS="__OKI_DISABLE_ANALYTICS__"
ENV OKI_INITIAL_CONFIG="__OKI_INITIAL_CONFIG__"

RUN apk add --no-cache git && \
    git clone --depth=1 https://github.com/Ouonnki/OuonnkiTV /build

WORKDIR /build

RUN npm install -g pnpm && \
    pnpm install && \
    pnpm build

# ============================================================
# 运行阶段：跟随目标架构
# ============================================================
FROM nginx:alpine

ARG BUILD_ARCH=amd64

LABEL \
  io.hass.name="OuonnkiTV" \
  io.hass.description="一键搭建个人影视站，支持TMDB智能模式，基于LibreTV修改" \
  io.hass.arch="${BUILD_ARCH}" \
  io.hass.type="addon" \
  maintainer="wuwweizn"

# 安装 jq（解析 HA options.json）
RUN apk add --no-cache jq

# nginx 监听 17380，SPA fallback
RUN printf 'server {\n\
    listen 17380;\n\
    root /usr/share/nginx/html;\n\
    index index.html;\n\
    location / {\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
}\n' > /etc/nginx/conf.d/default.conf

COPY --from=builder /build/dist /usr/share/nginx/html
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 17380

CMD ["/run.sh"]
