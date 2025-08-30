# 使用官方 Go 镜像作为构建镜像
FROM golang:1.19-buster AS builder

# 设置工作目录
WORKDIR /app

# 复制 go.mod 和 go.sum 文件
# 这里需要调整路径，确保 go.mod 被正确复制
COPY build/file-transfer-go/go.mod build/file-transfer-go/go.sum ./

# 下载 Go 依赖
RUN go mod tidy

# 复制其余的源代码到容器中
COPY build/file-transfer-go/ .

# 构建应用
RUN go build -o file-transfer-go .

# 使用更小的镜像来运行应用
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
