# 基于官方镜像构建Home Assistant加载项版本
FROM banksiae/alger-music-player:latest

# 添加标签信息
LABEL \
  io.hass.name="Alger Music Player" \
  io.hass.description="一个第三方音乐播放器，支持网易云音乐、本地服务、桌面歌词、音乐下载、远程控制" \
  io.hass.arch="aarch64|amd64|armv7" \
  io.hass.type="addon" \
  io.hass.version="1.0.0"

# 设置工作目录
WORKDIR /app

# 复制启动脚本
COPY run.sh /
RUN chmod a+x /run.sh

# 暴露端口
EXPOSE 8080

# 设置入口点
CMD [ "/run.sh" ]