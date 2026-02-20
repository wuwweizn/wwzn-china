# ==============================================================================
# XiaoMusic Home Assistant Add-on Dockerfile
#
# xiaomusic 官方镜像基于 distroless/精简镜像，没有包管理器（apk/apt 均不可用）
# 解决方案：多阶段构建
#   Stage 1 (builder): 用标准 Debian slim 镜像下载并安装 bashio 和工具
#   Stage 2 (final):   FROM xiaomusic 官方镜像，从 builder 中 COPY 进所需文件
# ==============================================================================

# ── Stage 1: 下载 bashio 和必要工具 ──────────────────────────────────────────
FROM debian:bookworm-slim AS builder

ARG BASHIO_VERSION="0.16.2"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       curl \
       ca-certificates \
       tar \
    && rm -rf /var/lib/apt/lists/*

# 下载并解压 bashio
RUN mkdir -p /usr/src/bashio \
    && curl -L -f -s \
       "https://github.com/hassio-addons/bashio/archive/v${BASHIO_VERSION}.tar.gz" \
       | tar -xzf - --strip 1 -C /usr/src/bashio \
    && mv /usr/src/bashio/lib /bashio-lib

# 下载 jq 静态二进制（无需安装，直接 COPY 使用）
RUN curl -L -f -s \
    "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64" \
    -o /usr/local/bin/jq-amd64 \
    && curl -L -f -s \
    "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-arm64" \
    -o /usr/local/bin/jq-arm64 \
    && curl -L -f -s \
    "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-armhf" \
    -o /usr/local/bin/jq-armv7 \
    && chmod +x /usr/local/bin/jq-*

# ── Stage 2: 最终镜像 ────────────────────────────────────────────────────────
ARG BUILD_FROM=hanxi/xiaomusic:latest
FROM ${BUILD_FROM}

# 从 builder 阶段复制 bashio（不依赖包管理器）
COPY --from=builder /bashio-lib /usr/lib/bashio
RUN ln -sf /usr/lib/bashio/bashio /usr/bin/bashio

# 复制对应架构的 jq 静态二进制
# 通过 BUILD_ARCH 参数区分（由 CI 传入）
ARG BUILD_ARCH=amd64
COPY --from=builder /usr/local/bin/jq-${BUILD_ARCH} /usr/bin/jq
RUN chmod +x /usr/bin/jq

# 确保 bash 存在（xiaomusic 镜像一般基于 python:slim，有 bash；distroless 没有）
# 如果没有 bash，用 sh 兜底
RUN if ! command -v bash > /dev/null 2>&1; then \
      ln -sf /bin/sh /bin/bash; \
    fi

# 复制启动脚本
COPY run.sh /run.sh
RUN chmod a+x /run.sh

# HA 标准标签
ARG BUILD_VERSION=unknown
LABEL \
    io.hass.name="XiaoMusic" \
    io.hass.description="使用小爱音箱播放音乐，音乐使用 yt-dlp 下载" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}"

EXPOSE 8090

CMD ["/run.sh"]
