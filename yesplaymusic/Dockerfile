FROM dnyo666/my_yesplaymusic:v0.4.16-3

# 添加标签
LABEL \
  io.hass.name="YesPlayMusic" \
  io.hass.description="高颜值的第三方网易云播放器" \
  io.hass.arch="armhf|armv7|aarch64|amd64|i386" \
  io.hass.type="addon" \
  io.hass.version="0.4.16-3"

# 安装必要工具和依赖
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    nodejs \
    npm \
    git

# 克隆并安装 NeteaseCloudMusicApi
WORKDIR /api
RUN git clone https://github.com/nooblong/NeteaseCloudMusicApiBackup.git . \
    && npm install

# 下载并安装 bashio
RUN curl -J -L -o /tmp/bashio.tar.gz \
    "https://github.com/hassio-addons/bashio/archive/v0.16.2.tar.gz" \
    && mkdir -p /tmp/bashio \
    && tar zxvf /tmp/bashio.tar.gz --strip 1 -C /tmp/bashio \
    && mv /tmp/bashio/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    && rm -rf /tmp/bashio.tar.gz /tmp/bashio

# 复制启动脚本
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# 暴露端口（80 为前端，3000 为 API）
EXPOSE 80 3000

# 设置工作目录
WORKDIR /

# 使用自定义启动脚本
ENTRYPOINT ["/usr/local/bin/run.sh"]