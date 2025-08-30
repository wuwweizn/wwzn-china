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

# 复制静态文件（如果需要）
COPY --from=build /tmp/src/web/dist /app/web/dist || true

# 从源码构建 file-transfer-go
# 安装构建依赖
RUN apk add --no-cache \
    git \
    go \
    nodejs \
    npm \
    build-base

# 克隆源码并构建
RUN git clone https://github.com/MatrixSeven/file-transfer-go.git /tmp/src && \
    cd /tmp/src && \
    # 构建前端
    cd web && \
    npm install && \
    npm run build && \
    cd .. && \
    # 构建后端
    go mod tidy && \
    CGO_ENABLED=0 GOOS=linux go build -o /app/file-transfer-go . && \
    # 清理
    rm -rf /tmp/src

# 或者使用预构建的 Docker 镜像方法
# COPY --from=matrixseven/file-transfer-go:latest /app/file-transfer-go /app/
# COPY --from=matrixseven/file-transfer-go:latest /app/web/dist /app/web/dist

# 暴露端口
EXPOSE 8080

# 启动脚本
CMD [ "/run.sh" ]