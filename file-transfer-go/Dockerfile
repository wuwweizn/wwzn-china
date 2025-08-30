# 使用一个基础 Go 镜像来构建 Go 程序
FROM golang:1.19-alpine AS builder

# 设置工作目录
WORKDIR /app

# 克隆源代码
RUN apk add --no-cache git
RUN git clone https://github.com/MatrixSeven/file-transfer-go.git /app

# 安装构建依赖
RUN apk add --no-cache build-base

# 编译 Go 程序
WORKDIR /app
RUN ./build-fullstack.sh

# 使用一个轻量级的 Alpine 镜像来运行程序
FROM alpine:3.18

# 设置工作目录
WORKDIR /app

# 复制构建好的二进制文件到镜像中
COPY --from=builder /app/dist/file-transfer-go /app/

# 公开端口
EXPOSE 8080

# 启动程序
CMD ["./file-transfer-go"]
