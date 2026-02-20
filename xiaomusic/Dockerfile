# =====================================================================
# XiaoMusic Home Assistant Add-on Dockerfile
# 基于官方镜像重新打标签，无需从源码构建，跟随上游自动更新
# 上游镜像: hanxi/xiaomusic
# 容器内服务端口: 8090
# =====================================================================

ARG BUILD_FROM=hanxi/xiaomusic:latest
FROM ${BUILD_FROM}

# HA Add-on 标准标签
LABEL \
    io.hass.name="XiaoMusic" \
    io.hass.description="使用小爱音箱播放音乐，音乐使用 yt-dlp 下载" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}" \
    maintainer="wuwweizn"

# 暴露服务端口
EXPOSE 8090
