ARG BUILD_FROM
FROM ${BUILD_FROM}

# 设置环境变量
ENV LANG C.UTF-8

# 安装必要的依赖
RUN apk add --no-cache \
    bash \
    curl \
    tzdata \
    ca-certificates

# 设置工作目录
WORKDIR /app

# 复制启动脚本
COPY run.sh /
RUN chmod a+x /run.sh

# 从原始镜像复制文件（这里假设我们基于官方镜像）
# 注意：你需要根据实际情况调整这部分
ARG TARGETARCH
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        curl -L -o file-transfer-go https://github.com/MatrixSeven/file-transfer-go/releases/latest/download/file-transfer-go-linux-amd64; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        curl -L -o file-transfer-go https://github.com/MatrixSeven/file-transfer-go/releases/latest/download/file-transfer-go-linux-arm64; \
    elif [ "$TARGETARCH" = "arm" ]; then \
        curl -L -o file-transfer-go https://github.com/MatrixSeven/file-transfer-go/releases/latest/download/file-transfer-go-linux-arm; \
    fi && \
    chmod +x file-transfer-go

# 或者如果没有预编译版本，从源码构建
# 这需要安装 Go 和 Node.js 环境
# RUN apk add --no-cache git go nodejs npm
# RUN git clone https://github.com/MatrixSeven/file-transfer-go.git . && \
#     chmod +x build-fullstack.sh && \
#     ./build-fullstack.sh

# 暴露端口
EXPOSE 8080

# 启动脚本
CMD [ "/run.sh" ]