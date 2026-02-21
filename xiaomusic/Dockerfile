FROM hanxi/xiaomusic:latest

ARG BUILD_ARCH=amd64

LABEL \
    io.hass.name="XiaoMusic" \
    io.hass.description="使用小爱音箱播放音乐，音乐使用 yt-dlp 下载。" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="0.3.101" \
    maintainer="wuwweizn"

# 创建 HA 风格的挂载目录
RUN mkdir -p /share/xiaomusic/music /config/xiaomusic

# 复制启动脚本
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 8090

CMD ["/run.sh"]
