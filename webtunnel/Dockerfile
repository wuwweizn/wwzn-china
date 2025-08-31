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

# 根据架构下载对应的 WebTunnel 二进制文件
ARG TARGETARCH
RUN case "${TARGETARCH}" in \
      "amd64") ARCH="x86_64" ;; \
      "arm64") ARCH="aarch64" ;; \
      "arm") ARCH="armv7" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    curl -fsSL "https://w.pgrm.top/download/docker/webtunnel_${ARCH}" -o /opt/webtunnel && \
    chmod +x /opt/webtunnel

# 创建配置目录
RUN mkdir -p /data

# 复制启动脚本
COPY run.sh /
RUN chmod a+x /run.sh

# 暴露端口
EXPOSE 8080

# 设置启动命令
CMD ["/run.sh"]