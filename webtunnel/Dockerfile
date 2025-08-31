ARG BUILD_FROM=ghcr.io/hassio-addons/base/amd64:15.0.1
FROM ${BUILD_FROM}

# 设置工作目录
WORKDIR /opt

# 安装必要的包
RUN apk add --no-cache \
    bash \
    curl \
    ca-certificates \
    tzdata

# 根据架构下载对应的 WebTunnel tar 包并解压
ARG TARGETARCH
RUN case "${TARGETARCH}" in \
      "amd64") ARCH="x64" ;; \
      "arm64") ARCH="arm64" ;; \
      "arm") echo "armv7 not available, using arm64"; ARCH="arm64" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    echo "Downloading WebTunnel for architecture: ${ARCH}" && \
    for i in 1 2 3; do \
      echo "Attempt ${i}/3..." && \
      curl -fsSL --connect-timeout 30 --max-time 300 \
        "https://w.pgrm.top/download/docker/webtunnel_${ARCH}-250828.tar" \
        -o /tmp/webtunnel.tar && break || \
      { echo "Download failed, retrying in 10 seconds..."; sleep 10; } \
    done && \
    [ -f /tmp/webtunnel.tar ] || { echo "Failed to download WebTunnel tar"; exit 1; } && \
    echo "Extracting WebTunnel..." && \
    cd /opt && \
    tar -xf /tmp/webtunnel.tar && \
    rm /tmp/webtunnel.tar && \
    # 查找并设置可执行权限
    find /opt -name "*webtunnel*" -type f -exec chmod +x {} \; && \
    # 如果有多个文件，创建符号链接到主要的可执行文件
    if [ ! -f /opt/webtunnel ] && [ -f /opt/webtunnel_* ]; then \
      ln -s /opt/webtunnel_* /opt/webtunnel; \
    fi && \
    echo "WebTunnel extracted and configured"

# 创建配置目录
RUN mkdir -p /data

# 复制启动脚本
COPY run.sh /
RUN chmod a+x /run.sh

# 暴露端口
EXPOSE 8080

# 设置启动命令
CMD ["/run.sh"]