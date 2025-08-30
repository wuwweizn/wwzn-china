# 使用官方 Golang 镜像进行构建
FROM golang:1.19 AS build

# 设置工作目录
WORKDIR /go/src/app

# 将源码复制到容器中
COPY build/ /go/src/app/

# 安装依赖并构建应用
RUN go mod tidy && go build -o file-transfer-go .

# 使用更轻量的运行时镜像
FROM debian:bullseye-slim

WORKDIR /app
# 从构建镜像中复制生成的二进制文件
COPY --from=build /go/src/app/file-transfer-go /app/

# 暴露端口
EXPOSE 8080

# 设置默认启动命令
CMD ["./file-transfer-go"]
