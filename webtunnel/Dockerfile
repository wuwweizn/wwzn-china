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
RUN echo "Target architecture: ${TARGETARCH}" && \
    case "${TARGETARCH}" in \
      "amd64") ARCH="x64" ;; \
      "arm64") ARCH="arm64" ;; \
      "arm") echo "armv7 not available, using arm64"; ARCH="arm64" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    echo "Mapped architecture: ${ARCH}" && \
    URL="https://w.pgrm.top/download/docker/webtunnel_${ARCH}-250828.tar" && \
    echo "Download URL: ${URL}"

# 分步执行以便调试
RUN TARGETARCH_VAL="${TARGETARCH:-amd64}" && \
    case "${TARGETARCH_VAL}" in \
      "amd64") ARCH="x64" ;; \
      "arm64") ARCH="arm64" ;; \
      *) ARCH="x64" ;; \
    esac && \
    echo "Downloading WebTunnel tar for ${ARCH}..." && \
    curl -fsSL --connect-timeout 30 --max-time 300 \
      "https://w.pgrm.top/download/docker/webtunnel_${ARCH}-250828.tar" \
      -o /tmp/webtunnel.tar

# 验证下载并解压
RUN echo "Checking downloaded file..." && \
    ls -la /tmp/webtunnel.tar && \
    file /tmp/webtunnel.tar && \
    echo "Extracting to /opt..." && \
    cd /opt && \
    tar -tf /tmp/webtunnel.tar && \
    tar -xf /tmp/webtunnel.tar && \
    echo "Files after extraction:" && \
    ls -la /opt/

# 设置权限和链接
RUN echo "Setting permissions..." && \
    find /opt -type f -exec file {} \; && \
    find /opt -name "*webtunnel*" -type f -exec chmod +x {} \; && \
    ls -la /opt/ && \
    if [ ! -f /opt/webtunnel ]; then \
      echo "Creating webtunnel symlink..." && \
      WEBTUNNEL_FILE=$(find /opt -name "*webtunnel*" -type f | head -1) && \
      echo "Found file: ${WEBTUNNEL_FILE}" && \
      if [ -n "${WEBTUNNEL_FILE}" ]; then \
        ln -sf "${WEBTUNNEL_FILE}" /opt/webtunnel; \
      fi; \
    fi && \
    echo "Final /opt contents:" && \
    ls -la /opt/ && \
    rm -f /tmp/webtunnel.tar

# 创建配置目录
RUN mkdir -p /data

# 复制启动脚本
COPY run.sh /
RUN chmod a+x /run.sh

# 暴露端口
EXPOSE 8080

# 设置启动命令
CMD ["/run.sh"]