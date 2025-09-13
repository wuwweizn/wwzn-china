FROM dnyo666/my_yesplaymusic:v0.4.16-3

# 添加标签
LABEL \
  io.hass.name="YesPlayMusic" \
  io.hass.description="高颜值的第三方网易云播放器" \
  io.hass.arch="armhf|armv7|aarch64|amd64|i386" \
  io.hass.type="addon" \
  io.hass.version="0.4.16-3"

# 安装必要工具
RUN apk add --no-cache \
    bash \
    curl \
    jq

# 下载并安装 bashio
RUN curl -J -L -o /tmp/bashio.tar.gz \
    "https://github.com/hassio-addons/bashio/archive/v0.16.2.tar.gz" \
    && mkdir -p /tmp/bashio \
    && tar zxvf /tmp/bashio.tar.gz --strip 1 -C /tmp/bashio \
    && mv /tmp/bashio/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    && rm -rf /tmp/bashio.tar.gz /tmp/bashio

# 复制 run.sh 到容器根目录
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# 暴露端口
EXPOSE 80

# 使用自定义启动脚本
ENTRYPOINT ["/usr/local/bin/run.sh"]