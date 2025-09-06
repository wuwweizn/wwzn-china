ARG BUILD_FROM=ghcr.io/home-assistant/base:stable
FROM ${BUILD_FROM}

# 安装必要工具
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    systemd \
    iptables \
    procps

# 复制脚本
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# 设置工作目录
WORKDIR /

# 启动脚本
CMD ["/usr/local/bin/run.sh"]