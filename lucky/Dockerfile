ARG BUILD_FROM=alpine:3.21.3
FROM ${BUILD_FROM}

# 设置构建参数
ARG BUILD_ARCH
ARG LUCKY_VERSION=2.17.8

# 设置环境变量
ENV LANG=C.UTF-8 \
    TZ=Asia/Shanghai \
    LUCKY_VERSION=${LUCKY_VERSION}

# 安装基础依赖
RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    curl \
    wget \
    bash \
    jq \
    openssl \
    su-exec \
    tini \
    shadow

# 下载Lucky二进制文件
RUN set -ex && \
    case "${BUILD_ARCH}" in \
        amd64) ARCH="amd64" ;; \
        aarch64) ARCH="arm64" ;; \
        armv7) ARCH="arm" ;; \
        armhf) ARCH="arm" ;; \
        i386) ARCH="386" ;; \
        *) echo "Unsupported architecture: ${BUILD_ARCH}" && exit 1 ;; \
    esac && \
    echo "Downloading Lucky for architecture: ${ARCH}" && \
    wget -O /tmp/lucky.tar.gz \
        "https://github.com/gdy666/lucky/releases/download/v${LUCKY_VERSION}/lucky_v${LUCKY_VERSION}_Linux_${ARCH}.tar.gz" && \
    tar -xzf /tmp/lucky.tar.gz -C /tmp && \
    mv /tmp/lucky /usr/local/bin/lucky && \
    chmod +x /usr/local/bin/lucky && \
    rm -rf /tmp/*

# 创建用户和目录
RUN addgroup -g 1000 lucky && \
    adduser -D -s /bin/bash -u 1000 -G lucky lucky && \
    mkdir -p /data/lucky /config && \
    chown -R lucky:lucky /data/lucky /config

# 复制启动脚本
COPY run.sh /run.sh
RUN chmod +x /run.sh

# 设置工作目录
WORKDIR /data/lucky

# 暴露端口
EXPOSE 16601

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:16601/ || exit 1

# 使用tini作为init进程
ENTRYPOINT ["/sbin/tini", "--"]

# 启动命令
CMD ["/run.sh"]