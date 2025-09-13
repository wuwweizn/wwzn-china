ARG BUILD_FROM=dnyo666/my_yesplaymusic:v0.4.16-3
FROM ${BUILD_FROM}

# 添加标签
LABEL \
  io.hass.name="YesPlayMusic" \
  io.hass.description="高颜值的第三方网易云播放器" \
  io.hass.arch="armhf|armv7|aarch64|amd64|i386" \
  io.hass.type="addon" \
  io.hass.version="0.4.16-3"

# 安装 bashio（Home Assistant 的 Bash 库）
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
    && rm -rf /tmp/bashio.tar.gz /tmp/bashio

# 复制启动脚本
COPY run.sh /
RUN chmod a+x /run.sh

# 暴露端口
EXPOSE 80

# 使用我们的启动脚本
CMD ["/run.sh"]