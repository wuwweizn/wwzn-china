# 使用官方 Alger Music Player 镜像
FROM banksiae/alger-music-player:latest

# 添加标签信息
LABEL \
  io.hass.name="Alger Music Player" \
  io.hass.description="一个第三方音乐播放器，支持网易云音乐、本地服务、桌面歌词、音乐下载、远程控制" \
  io.hass.arch="aarch64|amd64|armv7" \
  io.hass.type="addon" \
  io.hass.version="1.0.4"

# 安装 bashio（Home Assistant 的配置工具）
RUN apk add --no-cache \
    bash \
    curl \
    jq

# 下载并安装 bashio
RUN curl -J -L -o /tmp/bashio.tar.gz \
    "https://github.com/hassio-addons/bashio/archive/v0.16.2.tar.gz" \
    && mkdir /tmp/bashio \
    && tar zxvf /tmp/bashio.tar.gz --strip 1 -C /tmp/bashio \
    && mv /tmp/bashio/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    && rm -rf /tmp/bashio*

# 创建自定义启动脚本
COPY run.sh /usr/local/bin/run.sh
RUN chmod a+x /usr/local/bin/run.sh

# 修改原始的 docker-entrypoint.sh 来调用我们的脚本
RUN sed -i 's|exec "$@"|exec /usr/local/bin/run.sh|g' /docker-entrypoint.sh

# 暴露端口
EXPOSE 8080

# 使用原始入口点
CMD ["/docker-entrypoint.sh"]