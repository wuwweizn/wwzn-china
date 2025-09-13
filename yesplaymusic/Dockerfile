FROM dnyo666/my_yesplaymusic:v0.4.16-3

# 添加标签
LABEL \
  io.hass.name="YesPlayMusic" \
  io.hass.description="高颜值的第三方网易云播放器" \
  io.hass.arch="armhf|armv7|aarch64|amd64|i386" \
  io.hass.type="addon" \
  io.hass.version="0.4.16-3"

# 暴露端口
EXPOSE 80

# 不修改原始镜像的启动方式，直接使用原始的 ENTRYPOINT 和 CMD