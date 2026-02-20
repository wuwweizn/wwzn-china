# ==============================================================================
# XiaoMusic Home Assistant Add-on Dockerfile（多阶段构建）
#
# xiaomusic 官方镜像无包管理器，用多阶段构建注入 jq（读取 /data/options.json 用）
# 不再依赖 bashio / with-contenv，run.sh 用纯 bash + jq 实现
# ==============================================================================

# 全局 ARG 必须在第一个 FROM 之前，才能被后续 FROM ${BUILD_FROM} 引用
ARG BUILD_FROM=hanxi/xiaomusic:latest

# ── Stage 1: 下载 jq 静态二进制 ──────────────────────────────────────────────
FROM debian:bookworm-slim AS builder

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

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

# ── Stage 2: 最终镜像 ────────────────────────────────────────────────────────
FROM ${BUILD_FROM}

ARG BUILD_ARCH=amd64
ARG BUILD_VERSION=unknown

# 注入 jq（用于 run.sh 读取 /data/options.json）
COPY --from=builder /jq-${BUILD_ARCH} /usr/local/bin/jq
RUN chmod +x /usr/local/bin/jq

# 注入启动脚本
COPY run.sh /run.sh
RUN chmod +x /run.sh

LABEL \
    io.hass.name="XiaoMusic" \
    io.hass.description="使用小爱音箱播放音乐，音乐使用 yt-dlp 下载" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}"

EXPOSE 8090

CMD ["/bin/bash", "/run.sh"]
