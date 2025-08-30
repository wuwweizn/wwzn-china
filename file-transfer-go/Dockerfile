# ==============================================
# AMD64 Dockerfile - 基于 build-fullstack.sh 流程
# ==============================================

# 前端构建阶段
FROM node:20-alpine AS frontend-builder

# 安装 yarn
RUN apk add --no-cache yarn

WORKDIR /app/chuan-next

# 复制前端源代码
COPY chuan-next/package.json chuan-next/yarn.lock ./
RUN yarn install --frozen-lockfile --network-timeout 300000

# 清理构建文件（模拟 build-fullstack.sh 的 clean_all 函数）
RUN rm -rf .next out

# 临时移除 API 目录进行 SSG 构建（模拟 build-fullstack.sh 的 build_frontend 函数）
RUN if [ -d "src/app/api" ]; then mv src/app/api /tmp/api-backup; fi && \
    NEXT_EXPORT=true NODE_ENV=production NEXT_PUBLIC_BACKEND_URL= NEXT_PUBLIC_WS_URL= NEXT_PUBLIC_API_BASE_URL= yarn build && \
    if [ -d "/tmp/api-backup" ]; then mv /tmp/api-backup src/app/api; fi

# ==============================================

# Go 构建阶段
FROM golang:1.21-alpine AS go-builder

# 安装构建依赖
RUN apk add --no-cache git ca-certificates tzdata

# 设置 Go 环境变量
ENV GOPROXY=https://proxy.golang.org,direct
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64

WORKDIR /app

# 复制 Go 相关文件
COPY go.mod go.sum ./
RUN go mod download

# 拷贝前端构建结果
COPY --from=frontend-builder /app/chuan-next/out ./internal/web/frontend/

# 复制后端代码
COPY . .

# 构建 Go 应用 - AMD64 架构（模拟 build-fullstack.sh 的 build_backend 函数）
RUN go build -ldflags='-s -w -extldflags '-static'' -o server ./cmd

# ==============================================

# 最终镜像
FROM alpine:3.18

# 安装运行时依赖
RUN apk add --no-cache ca-certificates tzdata && \
    adduser -D -s /bin/sh appuser

WORKDIR /app

# 复制构建好的 Go 二进制文件到最终镜像
COPY --from=go-builder --chown=appuser:appuser /app/server ./ 

# 切换到非 root 用户
USER appuser

# 公开端口
EXPOSE 8080

# 启动应用
CMD ["./server"]
