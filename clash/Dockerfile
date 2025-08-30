# 根据目标架构设置基础镜像
ARG TARGETARCH
ARG BUILD_FROM=ghcr.io/hassio-addons/base:15.0.7

FROM ${BUILD_FROM}

# 设置环境变量
ENV LANG=C.UTF-8
ENV TZ=Asia/Shanghai

# 安装依赖
RUN apk add --no-cache \
    ca-certificates \
    wget \
    curl \
    jq \
    unzip \
    tzdata \
    bash

# 使用环境变量处理架构映射
ARG TARGETARCH
ENV TARGETARCH=${TARGETARCH}

# 下载并安装Clash.Meta (mihomo)
RUN echo "Building for architecture: ${TARGETARCH}" \
    && if [ "${TARGETARCH}" = "amd64" ]; then \
         CLASH_ARCH="amd64"; \
       elif [ "${TARGETARCH}" = "arm64" ]; then \
         CLASH_ARCH="arm64"; \
       elif [ "${TARGETARCH}" = "arm/v7" ] || [ "${TARGETARCH}" = "arm" ]; then \
         CLASH_ARCH="armv7"; \
       else \
         echo "Unsupported architecture: ${TARGETARCH}"; \
         exit 1; \
       fi \
    && echo "Using Clash.Meta architecture: ${CLASH_ARCH}" \
    && CLASH_VERSION=$(curl -s "https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" | jq -r .tag_name) \
    && echo "Downloading Clash.Meta ${CLASH_VERSION} for ${CLASH_ARCH}" \
    && wget -O /tmp/clash.gz "https://github.com/MetaCubeX/mihomo/releases/download/${CLASH_VERSION}/mihomo-linux-${CLASH_ARCH}-${CLASH_VERSION}.gz" \
    && gunzip /tmp/clash.gz \
    && mv /tmp/clash /usr/local/bin/clash \
    && chmod +x /usr/local/bin/clash \
    && clash -v

# 下载Clash Dashboard到允许的目录
RUN echo "Downloading Clash Dashboard..." \
    && wget -O /tmp/dashboard.zip "https://github.com/MetaCubeX/Yacd-meta/archive/gh-pages.zip" \
    && unzip /tmp/dashboard.zip -d /tmp \
    && mkdir -p /opt/clash/ui \
    && mv /tmp/Yacd-meta-gh-pages/* /opt/clash/ui/ \
    && rm -rf /tmp/dashboard.zip /tmp/Yacd-meta-gh-pages

# 下载GeoIP和GeoSite数据库
RUN echo "Downloading GeoIP and GeoSite databases..." \
    && mkdir -p /opt/clash \
    && wget -O /opt/clash/Country.mmdb "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country.mmdb" \
    && wget -O /opt/clash/geosite.dat "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat" \
    && wget -O /opt/clash/geoip.dat "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat"

# 创建必要的目录并设置权限
RUN mkdir -p /data/config /data/logs /opt/clash \
    && chmod 755 /data/config /data/logs /opt/clash /opt/clash/ui

# 复制启动脚本和配置文件
COPY run.sh /
COPY clash-config.yaml /opt/clash/default-config.yaml
RUN chmod +x /run.sh \
    && chmod 644 /opt/clash/default-config.yaml

# 设置工作目录
WORKDIR /data

# 暴露端口
EXPOSE 7890 7891 9090


# 启动命令
CMD ["/run.sh"]