FROM golang:1.19-alpine AS builder

# 设置工作目录
WORKDIR /app

# 安装依赖
RUN apk add --no-cache bash git build-base

# 克隆代码库
RUN git clone https://github.com/MatrixSeven/file-transfer-go.git /app/file-transfer-go

# 确认文件是否存在
RUN ls -l /app/file-transfer-go

# 切换到项目目录并确保构建脚本可执行
WORKDIR /app/file-transfer-go
RUN chmod +x build-fullstack.sh

# 构建
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
