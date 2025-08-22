# 多阶段构建 Dockerfile for SGCC Electricity
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

# 更新包索引并安装必要的系统包
RUN \
    apk update && \
    apk upgrade && \
    apk add --no-cache \
        python3 \
        py3-pip \
        python3-dev \
        gcc \
        g++ \
        musl-dev \
        libffi-dev \
        openssl-dev \
        git \
        curl \
        wget \
        tzdata \
        linux-headers \
        build-base \
    && rm -rf /var/cache/apk/* \
    && python3 -m ensurepip --upgrade \
    && pip3 install --upgrade pip setuptools wheel

# 设置时区
ENV TZ=Asia/Shanghai

# 创建工作目录
WORKDIR /app

# 从源仓库克隆最新代码（你可能需要调整这个）
RUN git clone https://github.com/ARC-MX/sgcc_electricity_new.git . \
    && rm -rf .git

# 复制启动脚本和依赖文件
COPY run.sh /app/run.sh
COPY requirements.txt /app/requirements.txt

# 设置权限
RUN chmod a+x /app/run.sh

# 安装 Python 依赖
RUN pip3 install --no-cache-dir -r requirements.txt

# 设置健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8123/health || exit 1

# 暴露端口
EXPOSE 8123

# 启动服务
CMD ["/app/run.sh"]