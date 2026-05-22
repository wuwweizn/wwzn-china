# ============================================================
# 构建阶段：固定 amd64，避免 lightningcss 等原生模块在 armv7
# 无预编译二进制时的编译失败问题。
# ============================================================
FROM --platform=linux/amd64 node:20-alpine AS builder

# 密码和视频源：空字符串构建（无密码/无预置源）
# 用户需要预置这些配置请使用应用内设置或 oki_initial_config
ENV OKI_ACCESS_PASSWORD=""
ENV OKI_INITIAL_VIDEO_SOURCES=""
ENV OKI_INITIAL_CONFIG=""
ENV OKI_DISABLE_ANALYTICS="true"

# TMDB 配置：用占位符，运行时替换（这类 URL 字符串 Vite 不会优化掉）
ENV OKI_TMDB_API_TOKEN="__OKI_TMDB_API_TOKEN__"
ENV OKI_TMDB_API_BASE_URL="__OKI_TMDB_API_BASE_URL__"
ENV OKI_TMDB_IMAGE_BASE_URL="__OKI_TMDB_IMAGE_BASE_URL__"

RUN apk add --no-cache git && \
    git clone --depth=1 https://github.com/Ouonnki/OuonnkiTV /build

WORKDIR /build

RUN npm install -g pnpm && \
    pnpm install && \
    pnpm build

# ============================================================
# 运行阶段
# ============================================================
FROM nginx:alpine

ARG BUILD_ARCH=amd64

LABEL \
  io.hass.name="OuonnkiTV" \
  io.hass.description="一键搭建个人影视站，支持TMDB智能模式，基于LibreTV修改" \
  io.hass.arch="${BUILD_ARCH}" \
  io.hass.type="addon" \
  maintainer="wuwweizn"

RUN apk add --no-cache jq

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