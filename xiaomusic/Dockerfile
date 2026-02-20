# ==============================================================================
# XiaoMusic Home Assistant Add-on Dockerfile（多阶段构建）
#
# Docker 多阶段构建 ARG 作用域规则：
#   - 需要在 FROM 中使用的 ARG，必须写在所有 FROM 之前（全局 ARG）
#   - 每个 FROM 之后，全局 ARG 自动失效，Stage 内若需使用须重新声明（无需赋值）
# ==============================================================================

# ── 全局 ARG（必须在第一个 FROM 之前，才能被 FROM ${BUILD_FROM} 引用） ───────
ARG BUILD_FROM=hanxi/xiaomusic:latest

# ── Stage 1: builder —— 下载 bashio 和 jq ───────────────────────────────────
FROM debian:bookworm-slim AS builder

ARG BASHIO_VERSION="0.16.2"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       curl \
       ca-certificates \
       tar \
    && rm -rf /var/lib/apt/lists/*

# 下载并解压 bashio 库
RUN mkdir -p /usr/src/bashio \
    && curl -L -f -s \
       "https://github.com/hassio-addons/bashio/archive/v${BASHIO_VERSION}.tar.gz" \
       | tar -xzf - --strip 1 -C /usr/src/bashio \
    && mv /usr/src/bashio/lib /bashio-lib

# 下载 jq 静态二进制（三种架构）
RUN curl -L -f -s \
      "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64" \
      -o /jq-amd64 \
    && curl -L -f -s \
      "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-arm64" \
      -o /jq-aarch64 \
    && curl -L -f -s \
      "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-armhf" \
      -o /jq-armv7 \
    && chmod +x /jq-*

# ── Stage 2: final —— 基于官方 xiaomusic 镜像 ───────────────────────────────
# BUILD_FROM 已在顶部全局声明，FROM 可直接引用
FROM ${BUILD_FROM}

# 进入新 Stage 后全局 ARG 失效，需重新声明才能在 RUN/COPY/LABEL 中使用
ARG BUILD_ARCH=amd64
ARG BUILD_VERSION=unknown

# 从 builder 复制 bashio（无需包管理器）
COPY --from=builder /bashio-lib /usr/lib/bashio
RUN ln -sf /usr/lib/bashio/bashio /usr/bin/bashio

# 复制对应架构的 jq 静态二进制
COPY --from=builder /jq-${BUILD_ARCH} /usr/bin/jq
RUN chmod +x /usr/bin/jq

# 如果镜像没有 bash，创建软链接兜底
RUN command -v bash || ln -sf /bin/sh /bin/bash

# 复制启动脚本
COPY run.sh /run.sh
RUN chmod a+x /run.sh

LABEL \
    io.hass.name="XiaoMusic" \
    io.hass.description="使用小爱音箱播放音乐，音乐使用 yt-dlp 下载" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}"

EXPOSE 8090

CMD ["/run.sh"]
