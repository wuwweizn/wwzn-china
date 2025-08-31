ARG BUILD_FROM=ghcr.io/hassio-addons/base/amd64:15.0.1
FROM ${BUILD_FROM}

# 设置工作目录
WORKDIR /opt

# 安装必要的包和网络工具
RUN apk add --no-cache \
    bash \
    curl \
    wget \
    ca-certificates \
    tzdata \
    bind-tools

# 根据架构下载对应的 WebTunnel tar 包
ARG TARGETARCH
RUN echo "=== WebTunnel Download Started ===" && \
    echo "Target architecture: ${TARGETARCH}" && \
    case "${TARGETARCH}" in \
      "amd64") ARCH="x64" ;; \
      "arm64") ARCH="arm64" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    echo "Mapped architecture: ${ARCH}" && \
    URL="https://w.pgrm.top/download/docker/webtunnel_${ARCH}-250828.tar" && \
    echo "Download URL: ${URL}" && \
    echo "=== Network Test ===" && \
    nslookup w.pgrm.top || echo "DNS lookup failed, continuing..." && \
    echo "=== Attempting Download ===" && \
    # 方法1: wget with extended timeout
    ( \
      echo "Trying wget (method 1)..." && \
      wget --timeout=300 --read-timeout=300 --tries=5 --waitretry=60 \
           --user-agent="Docker/1.0" --no-check-certificate \
           "${URL}" -O /tmp/webtunnel.tar && \
      echo "✓ wget download successful" \
    ) || \
    # 方法2: curl with different settings
    ( \
      echo "Trying curl (method 2)..." && \
      curl -L --insecure --connect-timeout 180 --max-time 900 \
           --retry 5 --retry-delay 60 --retry-max-time 3600 \
           --user-agent "Docker/1.0" --keepalive-time 30 \
           "${URL}" -o /tmp/webtunnel.tar && \
      echo "✓ curl download successful" \
    ) || \
    # 方法3: 尝试不同的 curl 配置
    ( \
      echo "Trying curl with HTTP/1.1 (method 3)..." && \
      curl -L --http1.1 --insecure --connect-timeout 120 --max-time 1200 \
           --retry 3 --retry-delay 90 \
           "${URL}" -o /tmp/webtunnel.tar && \
      echo "✓ curl HTTP/1.1 download successful" \
    ) || \
    ( \
      echo "❌ All download methods failed" && \
      echo "Available tools:" && \
      which curl wget || true && \
      echo "Network connectivity test:" && \
      ping -c 3 8.8.8.8 || true && \
      exit 1 \
    )

# 验证下载的文件并解压
RUN echo "=== File Verification ===" && \
    if [ -f /tmp/webtunnel.tar ]; then \
      echo "File downloaded successfully:" && \
      ls -la /tmp/webtunnel.tar && \
      file /tmp/webtunnel.tar && \
      echo "=== Extracting Archive ===" && \
      cd /opt && \
      echo "Archive contents:" && \
      tar -tf /tmp/webtunnel.tar | head -10 && \
      tar -xf /tmp/webtunnel.tar && \
      rm /tmp/webtunnel.tar && \
      echo "=== Files After Extraction ===" && \
      ls -la /opt/ && \
      find /opt -name "*webtunnel*" -type f && \
      echo "=== Setting Permissions ===" && \
      find /opt -name "*webtunnel*" -type f -exec chmod +x {} \; && \
      if [ ! -f /opt/webtunnel ]; then \
        WEBTUNNEL_FILE=$(find /opt -name "*webtunnel*" -type f -executable | head -1) && \
        if [ -n "${WEBTUNNEL_FILE}" ]; then \
          echo "Creating symlink: ${WEBTUNNEL_FILE} -> /opt/webtunnel" && \
          ln -sf "${WEBTUNNEL_FILE}" /opt/webtunnel; \
        else \
          echo "ERROR: No executable webtunnel file found!" && \
          find /opt -type f -exec file {} \; && \
          exit 1; \
        fi; \
      fi && \
      echo "=== Setup Complete ===" && \
      ls -la /opt/ && \
      echo "WebTunnel binary info:" && \
      file /opt/webtunnel && \
      echo "✓ WebTunnel installation successful"; \
    else \
      echo "❌ Download failed - no file found" && \
      exit 1; \
    fi

# 创建配置目录
RUN mkdir -p /data

# 复制启动脚本
COPY run.sh /
RUN chmod a+x /run.sh

# 暴露端口
EXPOSE 8080

# 设置启动命令
CMD ["/run.sh"]