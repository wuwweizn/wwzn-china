# 使用 Python 官方 Alpine 镜像作为基础
ARG BUILD_ARCH
FROM python:3.11-alpine

# 设置构建参数
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION="SGCC Electricity HomeAssistant Addon"
ARG BUILD_NAME="SGCC Electricity"
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

# 安装 bashio 和其他必要的系统包
RUN \
    apk update && \
    apk add --no-cache \
        bash \
        curl \
        wget \
        git \
        jq \
        tzdata \
        gcc \
        musl-dev \
        linux-headers \
        libffi-dev \
        openssl-dev \
    && rm -rf /var/cache/apk/* \
    && pip install --no-cache-dir bashio

# 设置时区
ENV TZ=Asia/Shanghai

# 创建工作目录
WORKDIR /app

# 先复制依赖文件并安装
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# 从源仓库克隆最新代码
RUN \
    git clone https://github.com/ARC-MX/sgcc_electricity_new.git /tmp/sgcc_src && \
    cp -r /tmp/sgcc_src/* /app/ && \
    rm -rf /tmp/sgcc_src

# 复制启动脚本
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# 创建数据目录
RUN mkdir -p /data /share

# 设置健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD pgrep -f python3 || exit 1

# 暴露端口
EXPOSE 8123

# 启动服务
CMD ["/app/run.sh"]