# 第一阶段：下载和准备文件
FROM alpine:latest AS downloader

RUN apk add --no-cache curl file

ARG TARGETARCH
WORKDIR /download

RUN echo "Architecture: ${TARGETARCH}" && \
    if [ "${TARGETARCH}" = "amd64" ]; then \
        ARCH="x64"; \
    elif [ "${TARGETARCH}" = "arm64" ]; then \
        ARCH="arm64"; \
    else \
        echo "Unsupported architecture: ${TARGETARCH}"; \
        exit 1; \
    fi && \
    echo "Downloading webtunnel_${ARCH}-250828.tar..." && \
    curl -fL "https://w.pgrm.top/download/docker/webtunnel_${ARCH}-250828.tar" -o webtunnel.tar && \
    echo "Downloaded file info:" && \
    ls -la webtunnel.tar && \
    file webtunnel.tar && \
    echo "Extracting tar file..." && \
    tar -xf webtunnel.tar && \
    ls -la . && \
    echo "Making files executable..." && \
    find . -name "*webtunnel*" -type f -exec chmod +x {} \; && \
    find . -type f -exec file {} \;

# 第二阶段：构建最终镜像
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

# 从第一阶段复制文件
COPY --from=downloader /download/ /opt/

# 确保有一个 webtunnel 可执行文件
RUN ls -la /opt/ && \
    if [ ! -f /opt/webtunnel ]; then \
        WEBTUNNEL_FILE=$(find /opt -name "*webtunnel*" -type f -executable | head -1); \
        if [ -n "${WEBTUNNEL_FILE}" ]; then \
            echo "Creating symlink: ${WEBTUNNEL_FILE} -> /opt/webtunnel"; \
            ln -sf "${WEBTUNNEL_FILE}" /opt/webtunnel; \
        else \
            echo "No webtunnel executable found!"; \
            exit 1; \
        fi; \
    fi && \
    chmod +x /opt/webtunnel && \
    echo "Final setup complete:" && \
    ls -la /opt/

# 创建配置目录
RUN mkdir -p /data

# 复制启动脚本
COPY run.sh /
RUN chmod a+x /run.sh

# 暴露端口
EXPOSE 8080

# 设置启动命令
CMD ["/run.sh"]