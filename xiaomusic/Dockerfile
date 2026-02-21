ARG BUILD_FROM=ghcr.io/hassio-addons/base:latest
ARG BUILD_ARCH=amd64

# ─── 阶段1：从官方镜像提取程序文件 ───────────────────────────────────────────
FROM hanxi/xiaomusic:latest AS upstream

# ─── 阶段2：基于 HA 官方 base 镜像构建 Add-on ────────────────────────────────
FROM $BUILD_FROM

# 设置构建架构标签
ARG BUILD_ARCH
LABEL \
    io.hass.name="XiaoMusic" \
    io.hass.description="使用小爱音箱播放音乐，音乐使用 yt-dlp 下载。" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="0.3.101" \
    maintainer="wuwweizn"

# 复制官方镜像中的应用文件
COPY --from=upstream /app /app
COPY --from=upstream /usr/local/lib/python3.12 /usr/local/lib/python3.12
COPY --from=upstream /usr/local/bin/xiaomusic /usr/local/bin/xiaomusic
COPY --from=upstream /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg 2>/dev/null || true
COPY --from=upstream /usr/local/bin/yt-dlp /usr/local/bin/yt-dlp 2>/dev/null || true
COPY --from=upstream /usr/bin/ffmpeg /usr/bin/ffmpeg 2>/dev/null || true

# 安装 Python3 运行时依赖（HA base 镜像是 Alpine）
RUN apk add --no-cache \
    python3 \
    py3-pip \
    ffmpeg \
    && pip3 install --no-cache-dir --break-system-packages xiaomusic \
    && rm -rf /var/cache/apk/*

# 创建数据目录
RUN mkdir -p /share/xiaomusic/music /config/xiaomusic

# 复制启动脚本
COPY run.sh /run.sh
RUN chmod +x /run.sh

# 暴露端口
EXPOSE 8090

CMD ["/run.sh"]
