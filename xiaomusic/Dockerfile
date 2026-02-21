FROM hanxi/xiaomusic:latest

ARG BUILD_ARCH=amd64

LABEL \
    io.hass.name="XiaoMusic" \
    io.hass.description="使用小爱音箱播放音乐，音乐使用 yt-dlp 下载。" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="0.3.101" \
    maintainer="wuwweizn"

# 官方镜像的数据目录就是 /app/music 和 /app/conf，不需要改动
# HA 的 map 会把 /share 和 /config 挂进来，我们在 run.sh 里用软链接桥接

COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 8090

CMD ["/run.sh"]
