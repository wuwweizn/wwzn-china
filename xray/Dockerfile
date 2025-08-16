# 根据目标架构设置基础镜像
ARG TARGETARCH
ARG BUILD_FROM=ghcr.io/hassio-addons/base:15.0.7

FROM ${BUILD_FROM}

# 设置环境变量
ENV LANG C.UTF-8

# 安装依赖
RUN apk add --no-cache \
    ca-certificates \
    wget \
    unzip \
    jq

# 获取架构信息并设置XRay架构名称
ARG TARGETARCH
RUN case "${TARGETARCH}" in \
        "amd64")  XRAY_ARCH="64" ;; \
        "arm64")  XRAY_ARCH="arm64-v8a" ;; \
        "arm")    XRAY_ARCH="arm32-v7a" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac \
    && echo "XRAY_ARCH=${XRAY_ARCH}" > /tmp/xray_arch

# 下载并安装XRay
RUN . /tmp/xray_arch \
    && XRAY_VERSION=$(wget -qO- "https://api.github.com/repos/XTLS/Xray-core/releases/latest" | jq -r .tag_name) \
    && echo "Downloading XRay ${XRAY_VERSION} for ${XRAY_ARCH}" \
    && wget -O /tmp/xray.zip "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-${XRAY_ARCH}.zip" \
    && unzip /tmp/xray.zip -d /tmp/xray \
    && mv /tmp/xray/xray /usr/local/bin/xray \
    && chmod +x /usr/local/bin/xray \
    && rm -rf /tmp/xray.zip /tmp/xray /tmp/xray_arch

# 创建配置目录
RUN mkdir -p /data/config

# 复制启动脚本
COPY run.sh /
RUN chmod a+x /run.sh

# 设置默认配置文件路径
ENV XRAY_CONF_PATH="/data/config/config.json"

WORKDIR /data
CMD [ "/run.sh" ]