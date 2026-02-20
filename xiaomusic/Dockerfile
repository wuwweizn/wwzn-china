# ==============================================================================
# XiaoMusic Home Assistant Add-on Dockerfile
#
# 基于官方镜像，安装 bashio（HA 脚本工具库），注入 run.sh 启动脚本
# bashio 安装方式参考 HA 官方 docker-base 仓库
# ==============================================================================

ARG BUILD_FROM=hanxi/xiaomusic:latest
FROM ${BUILD_FROM}

# 安装 bashio 所需的依赖工具
RUN apk add --no-cache \
    bash \
    curl \
    jq

# 安装 bashio（HA 官方方式）
ARG BASHIO_VERSION="0.16.2"
RUN mkdir -p /usr/src/bashio \
    && curl -L -f -s \
       "https://github.com/hassio-addons/bashio/archive/v${BASHIO_VERSION}.tar.gz" \
       | tar -xzf - --strip 1 -C /usr/src/bashio \
    && mv /usr/src/bashio/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
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
