# ==============================================================================
# XiaoMusic Home Assistant Add-on Dockerfile
#
# 官方镜像基于 Debian/Python，使用 apt-get 而非 apk
# ==============================================================================

ARG BUILD_FROM=hanxi/xiaomusic:latest
FROM ${BUILD_FROM}

# 安装 bashio 依赖（Debian 系用 apt-get）
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       bash \
       curl \
       jq \
    && rm -rf /var/lib/apt/lists/*

# 安装 bashio（HA 官方方式）
ARG BASHIO_VERSION="0.16.2"
RUN mkdir -p /usr/src/bashio \
    && curl -L -f -s \
       "https://github.com/hassio-addons/bashio/archive/v${BASHIO_VERSION}.tar.gz" \
       | tar -xzf - --strip 1 -C /usr/src/bashio \
    && mv /usr/src/bashio/lib /usr/lib/bashio \
    && ln -sf /usr/lib/bashio/bashio /usr/bin/bashio \
    && rm -rf /usr/src/bashio

# 复制启动脚本
COPY run.sh /run.sh
RUN chmod a+x /run.sh

# HA 标准标签
ARG BUILD_VERSION=unknown
LABEL \
    io.hass.name="XiaoMusic" \
    io.hass.description="使用小爱音箱播放音乐，音乐使用 yt-dlp 下载" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}"

EXPOSE 8090

CMD ["/run.sh"]
