# ha-system-proxy/Dockerfile
ARG BUILD_FROM=ghcr.io/hassio-addons/base:15.0.7
FROM ${BUILD_FROM}

# Home Assistant labels
LABEL \
    io.hass.name="HA System Proxy" \
    io.hass.description="Configure system-wide proxy for Home Assistant OS" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="1.0.0" \
    maintainer="wuwweizn" \
    org.opencontainers.image.title="Home Assistant System Proxy Add-on" \
    org.opencontainers.image.description="Configure system-wide proxy for Home Assistant OS" \
    org.opencontainers.image.source="https://github.com/wuwweizn/wwzn-china" \
    org.opencontainers.image.licenses="MIT"

# 安装必要工具
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    iptables \
    procps \
    net-tools

# 复制脚本
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# 设置工作目录
WORKDIR /

# 启动脚本
CMD ["/usr/local/bin/run.sh"]