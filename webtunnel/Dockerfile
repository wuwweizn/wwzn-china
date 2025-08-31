# 第一阶段：专门用于下载
FROM alpine:latest AS downloader

# 安装下载工具和网络诊断工具
RUN apk add --no-cache \
    curl \
    wget \
    ca-certificates \
    openssl \
    bind-tools \
    net-tools

ARG TARGETARCH
WORKDIR /download

# 网络诊断和优化下载
RUN echo "=== Network Diagnostics ===" && \
    nslookup w.pgrm.top && \
    echo "=== Starting Download ===" && \
    case "${TARGETARCH}" in \
      "amd64") ARCH="x64" ;; \
      "arm64") ARCH="arm64" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    URL="https://w.pgrm.top/download/docker/webtunnel_${ARCH}-250828.tar" && \
    echo "Downloading from: ${URL}" && \
    # 使用多种方法和更宽松的超时设置
    ( \
      echo "Method 1: wget with long timeout..." && \
      wget --timeout=300 --read-timeout=300 --tries=3 --waitretry=30 \
           --user-agent="Mozilla/5.0 (compatible; Docker-build)" \
           "${URL}" -O webtunnel.tar && \
      echo "wget succeeded" \
    ) || ( \
      echo "Method 2: curl with extended options..." && \
      curl -L --connect-timeout 120 --max-time 600 --retry 5 --retry-delay 30 \
           --user-agent "Mozilla/5.0 (compatible; Docker-build)" \
           --keepalive-time 60 --tcp-keepalive \
           "${URL}" -o webtunnel.tar && \
      echo "curl succeeded" \
    ) || ( \
      echo "Method 3: curl with different settings..." && \
      curl -L --http1.1 --connect-timeout 60 --max-time 900 \
           --retry 3 --retry-max-time 1800 \
           "${URL}" -o webtunnel.tar && \
      echo "curl http1.1 succeeded" \
    ) || ( \
      echo "All download methods failed, checking what we have:" && \
      ls -la . && \
      exit 1 \
    ) && \
    echo "Download successful!" && \
    ls -la webtunnel.tar && \
    file webtunnel.tar

# 验证和解压
RUN echo "Verifying and extracting tar file..." && \
    tar -tf webtunnel.tar | head -10 && \
    tar -xf webtunnel.tar && \
    ls -la . && \
    find . -name "*webtunnel*" -type f -exec chmod +x {} \; && \
    echo "Extraction complete"

# 第二阶段：构建最终镜像
ARG BUILD_FROM=ghcr.io/hassio-addons/base/amd64:15.0.1
ARG TARGETARCH
FROM ${BUILD_FROM}

# 设置工作目录
WORKDIR /opt

# 安装必要的包
RUN apk add --no-cache \
    bash \
    ca-certificates \
    tzdata

# 从第一阶段复制文件
COPY --from=downloader /download/ /opt/

# 设置 WebTunnel 可执行文件
RUN echo "Setting up WebTunnel..." && \
    ls -la /opt/ && \
    if [ ! -f /opt/webtunnel ]; then \
        WEBTUNNEL_FILE=$(find /opt -name "*webtunnel*" -type f -executable | head -1); \
        if [ -n "${WEBTUNNEL_FILE}" ]; then \
            echo "Creating symlink: ${WEBTUNNEL_FILE} -> /opt/webtunnel"; \
            ln -sf "${WEBTUNNEL_FILE}" /opt/webtunnel; \
        else \
            echo "ERROR: No webtunnel executable found!"; \
            find /opt -type f -exec file {} \; ; \
            exit 1; \
        fi; \
    fi && \
    chmod +x /opt/webtunnel && \
    echo "Final setup:" && \
    ls -la /opt/ && \
    /opt/webtunnel --version || echo "Version check failed but continuing..."

# 创建配置目录
RUN mkdir -p /data

# 复制启动脚本
COPY run.sh /
RUN chmod a+x /run.sh

# 暴露端口
EXPOSE 8080

# 设置启动命令
CMD ["/run.sh"]