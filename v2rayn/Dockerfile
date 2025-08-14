ARG BUILD_FROM=alpine:3.21.3
FROM $BUILD_FROM

# 构建参数
ARG BUILD_ARCH
ARG V2RAYN_VERSION

# 设置环境变量
ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
    PATH="/usr/local/bin:$PATH"

# 标签
LABEL \
    io.hass.name="v2rayN" \
    io.hass.description="v2rayN proxy client for Home Assistant" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="${V2RAYN_VERSION}" \
    maintainer="wwzn <wwzn@example.com>" \
    org.opencontainers.image.title="v2rayN Home Assistant Add-on" \
    org.opencontainers.image.description="v2rayN proxy client integrated with Home Assistant" \
    org.opencontainers.image.source="https://github.com/wuwweizn/wwzn-china" \
    org.opencontainers.image.authors="wwzn <wwzn@example.com>"

# 安装系统依赖
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    ca-certificates \
    tzdata \
    s6-overlay \
    supervisor \
    unzip \
    wget \
    dumb-init \
    && rm -rf /var/cache/apk/*

# 根据架构设置下载URL
RUN case "${BUILD_ARCH}" in \
    amd64) V2RAY_ARCH="64" ;; \
    aarch64) V2RAY_ARCH="arm64-v8a" ;; \
    armv7) V2RAY_ARCH="arm32-v7a" ;; \
    *) echo "Unsupported architecture: ${BUILD_ARCH}" && exit 1 ;; \
    esac \
    && echo "Architecture: ${BUILD_ARCH}, V2Ray arch: ${V2RAY_ARCH}" \
    # 下载并安装 v2ray 核心
    && DOWNLOAD_URL="https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-${V2RAY_ARCH}.zip" \
    && echo "Downloading v2ray core from: ${DOWNLOAD_URL}" \
    && wget -q "${DOWNLOAD_URL}" -O v2ray.zip \
    && unzip -q v2ray.zip -d /usr/local/bin/ \
    && rm v2ray.zip \
    && chmod +x /usr/local/bin/v2ray \
    # 下载并安装 xray 核心
    && XRAY_URL="https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-${V2RAY_ARCH}.zip" \
    && echo "Downloading xray core from: ${XRAY_URL}" \
    && wget -q "${XRAY_URL}" -O xray.zip \
    && unzip -q xray.zip -d /tmp/xray \
    && mv /tmp/xray/xray /usr/local/bin/xray \
    && rm -rf xray.zip /tmp/xray \
    && chmod +x /usr/local/bin/xray \
    # 下载 geo 数据文件
    && wget -q https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat -O /usr/local/bin/geosite.dat \
    && wget -q https://github.com/v2fly/geoip/releases/latest/download/geoip.dat -O /usr/local/bin/geoip.dat

# 创建必要的目录
RUN mkdir -p \
    /etc/services.d/v2rayn \
    /etc/cont-init.d \
    /var/log/v2rayn \
    /data/v2rayn \
    /share/v2rayn \
    /tmp

# 复制配置文件和脚本
COPY rootfs/ /

# 设置权限
RUN chmod a+x /etc/services.d/v2rayn/run \
    && chmod a+x /etc/services.d/v2rayn/finish \
    && chmod a+x /etc/cont-init.d/* \
    && chmod a+x /usr/local/bin/v2rayn-manager.sh

# 创建用户
RUN addgroup -g 1000 v2rayn \
    && adduser -D -s /bin/bash -u 1000 -G v2rayn v2rayn \
    && chown -R v2rayn:v2rayn /data/v2rayn /var/log/v2rayn /share/v2rayn

# 暴露端口
EXPOSE 1080 1081 8080 10808 10809

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# 工作目录
WORKDIR /data/v2rayn

# 使用 S6 overlay 作为 init 系统
ENTRYPOINT ["/init"]