# 使用正确的基础镜像
ARG BUILD_ARCH
FROM ghcr.io/hassio-addons/base:15.0.7

# 设置构建参数
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# 设置标签
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="wuwweizn" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="WWZN China Repository" \
    org.opencontainers.image.authors="wuwweizn" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/wuwweizn/wwzn-china" \
    org.opencontainers.image.source="https://github.com/wuwweizn/wwzn-china" \
    org.opencontainers.image.documentation="https://github.com/wuwweizn/wwzn-china/blob/main/sgcc_electricity/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

# 安装 Python 和其他系统包
RUN \
    apk update && \
    apk add --no-cache \
        python3 \
        py3-pip \
        python3-dev \
        git \
        curl \
        wget \
        gcc \
        g++ \
        musl-dev \
        libffi-dev \
        openssl-dev \
        linux-headers \
        build-base \
    && rm -rf /var/cache/apk/* \
    && python3 -m ensurepip --upgrade \
    && pip3 install --upgrade pip setuptools wheel

# 设置时区
ENV TZ=Asia/Shanghai

# 创建工作目录
WORKDIR /app

# 先复制依赖文件
COPY requirements.txt /tmp/requirements.txt

# 升级 pip 并安装 Python 依赖
RUN \
    pip3 install --upgrade pip setuptools wheel && \
    pip3 install --no-cache-dir -r /tmp/requirements.txt && \
    rm -f /tmp/requirements.txt

# 从源仓库克隆最新代码
RUN \
    git clone https://github.com/ARC-MX/sgcc_electricity_new.git /app/sgcc_src && \
    cp -r /app/sgcc_src/* /app/ && \
    rm -rf /app/sgcc_src /app/.git

# 复制启动脚本
COPY run.sh /app/run.sh
RUN chmod a+x /app/run.sh

# 设置健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8123/health || exit 1

# 暴露端口
EXPOSE 8123

# 启动服务
CMD ["/app/run.sh"]