# 多阶段构建
FROM golang:1.21-alpine AS go-builder

# 安装构建依赖
RUN apk add --no-cache git build-base

# 设置工作目录
WORKDIR /src

# 克隆源码
RUN git clone https://github.com/MatrixSeven/file-transfer-go.git .

# 构建 Go 应用
RUN go mod tidy && \
    CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o file-transfer-go .

# Node.js 构建阶段
FROM node:18-alpine AS node-builder

WORKDIR /src

# 复制前端源码
COPY --from=go-builder /src/web ./web

# 构建前端
WORKDIR /src/web
RUN npm install && npm run build

# 最终运行时镜像
ARG BUILD_FROM
FROM ${BUILD_FROM}

# 设置环境变量
ENV LANG=C.UTF-8

# 安装运行时依赖
RUN apk add --no-cache \
    bash \
    curl \
    tzdata \
    ca-certificates

# 设置工作目录
WORKDIR /app

# 从构建阶段复制文件
COPY --from=go-builder /src/file-transfer-go /app/file-transfer-go
COPY --from=node-builder /src/web/dist /app/web/dist

# 复制启动脚本
COPY run.sh /
RUN chmod a+x /run.sh && \
    chmod +x /app/file-transfer-go

# 暴露端口
EXPOSE 8080

# 启动脚本
CMD [ "/run.sh" ]