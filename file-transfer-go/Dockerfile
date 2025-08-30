# 使用官方 Go 镜像作为构建镜像
FROM golang:1.19-buster AS builder

# 设置工作目录
WORKDIR /app

# 将源代码复制到容器中
COPY . .

# 下载 Go 依赖并构建应用
RUN go mod tidy && go build -o file-transfer-go .

# 使用更小的镜像运行应用
FROM debian:bullseye-slim

# 安装必要的依赖
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 从构建镜像中复制构建好的二进制文件
COPY --from=builder /app/file-transfer-go /app/file-transfer-go

# 开放 8080 端口
EXPOSE 8080

# 设置容器启动时执行的命令
CMD ["/app/file-transfer-go"]
