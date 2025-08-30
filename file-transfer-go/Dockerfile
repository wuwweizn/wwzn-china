# 基于官方 Golang 镜像
FROM golang:1.19 AS build

# 设置工作目录
WORKDIR /go/src/app

# 复制源码到工作目录
COPY build/ /go/src/app/

# 安装依赖并构建
RUN go mod tidy && go build -o file-transfer-go .

# 使用更轻量的镜像来运行应用
FROM debian:bullseye-slim

WORKDIR /app
COPY --from=build /go/src/app/file-transfer-go /app/

# 暴露端口
EXPOSE 8080

# 设置默认启动命令
CMD ["./file-transfer-go"]
