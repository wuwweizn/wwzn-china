ARG BUILD_FROM=alpine:3.21.3
FROM ${BUILD_FROM}

# 设置构建参数
ARG BUILD_ARCH
ARG ALIST_VERSION=3.41.0

# 设置环境变量
ENV LANG=C.UTF-8 \
    TZ=Asia/Shanghai \
    PUID=0 \
    PGID=0 \
    UMASK=022 \
    ALIST_VERSION=${ALIST_VERSION}

# 安装基础依赖
RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    curl \
    wget \
    bash \
    jq \
    su-exec \
    tini \
    shadow \
    ffmpeg \
    aria2

# 设置工作目录
WORKDIR /opt/alist

# 下载Alist二进制文件
RUN set -ex && \
    case "${BUILD_ARCH}" in \
        amd64) ARCH="amd64" ;; \
        aarch64) ARCH="arm64" ;; \
        armv7) ARCH="armv7" ;; \
        armhf) ARCH="armv6" ;; \
        i386) ARCH="386" ;; \
        *) echo "Unsupported architecture: ${BUILD_ARCH}" && exit 1 ;; \
    esac && \
    echo "Downloading Alist for architecture: ${ARCH}" && \
    wget -O /tmp/alist.tar.gz \
        "https://github.com/AlistGo/alist/releases/download/v${ALIST_VERSION}/alist-linux-${ARCH}.tar.gz" && \
    tar -xzf /tmp/alist.tar.gz -C /tmp && \
    mv /tmp/alist /opt/alist/alist && \
    chmod +x /opt/alist/alist && \
    rm -rf /tmp/*

# 创建用户和目录
RUN addgroup -g 1000 alist && \
    adduser -D -s /bin/bash -u 1000 -G alist alist && \
    mkdir -p /opt/alist/data /config /downloads && \
    chown -R alist:alist /opt/alist /config /downloads

# 复制启动脚本和配置文件
COPY run.sh /run.sh
COPY rootfs/ /

RUN chmod +x /run.sh

# 设置工作目录
WORKDIR /opt/alist

# 创建数据卷
VOLUME ["/opt/alist/data"]

# 暴露端口
EXPOSE 5244

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:5244/ || exit 1

# 使用tini作为init进程
ENTRYPOINT ["/sbin/tini", "--"]

# 启动命令
CMD ["/run.sh"]