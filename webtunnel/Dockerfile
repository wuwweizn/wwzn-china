# 使用轻量级基础镜像
FROM alpine:3.21.2

# 支持 buildx 的平台变量
ARG TARGETPLATFORM

# 安装依赖
RUN apk add --no-cache wget tar libstdc++ libgcc libc6-compat

# 工作目录
WORKDIR /tmp

# 下载并解压对应架构的 WebTunnelCore
RUN echo "TARGETPLATFORM=$TARGETPLATFORM" && \
    case "$TARGETPLATFORM" in \
      linux/amd64) wget -O WebTunnelCore.tar.gz https://w.pgrm.top/download/linux/WebTunnelCore-linux-x64-250612.tar.gz ;; \
      linux/arm64) wget -O WebTunnelCore.tar.gz https://w.pgrm.top/download/linux/WebTunnelCore-linux-arm64-250612.tar.gz ;; \
      *) echo "Unsupported platform $TARGETPLATFORM" && exit 1 ;; \
    esac && \
    tar -xzvf WebTunnelCore.tar.gz -C / && \
    chmod +x "/WebTunnelCore" && \
    rm -rf /tmp/*

# 默认挂载目录（用于保存配置文件）
VOLUME ["/data/.webtunnel"]

# 设置容器启动入口
ENTRYPOINT ["/WebTunnelCore", "--config=/data/.webtunnel"]
