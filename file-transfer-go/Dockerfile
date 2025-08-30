FROM golang:1.19-alpine AS builder

# 设置工作目录
WORKDIR /app

# 安装依赖
RUN apk add --no-cache bash git build-base

# 克隆代码库
RUN git clone https://github.com/MatrixSeven/file-transfer-go.git /app

# 确保构建脚本可执行
RUN chmod +x /app/file-transfer-go/build-fullstack.sh

# 切换到项目目录并构建
WORKDIR /app/file-transfer-go
RUN ./build-fullstack.sh

# 使用轻量的 Alpine 镜像
FROM alpine:3.18

# 设置工作目录
WORKDIR /app

# 复制构建的二进制文件
COPY --from=builder /app/file-transfer-go/dist/file-transfer-go /app/

# 公开端口
EXPOSE 8080

# 启动程序
CMD ["./file-transfer-go"]
