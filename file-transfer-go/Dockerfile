# ==============================================
# 阶段 1：前端构建阶段
# ==============================================
FROM node:20-alpine AS frontend-builder

# 安装 yarn
RUN apk add --no-cache yarn

WORKDIR /app/chuan-next

# 克隆 GitHub 仓库并进入前端目录
RUN git clone https://github.com/MatrixSeven/file-transfer-go.git /app
WORKDIR /app/file-transfer-go/chuan-next

# 安装前端依赖
COPY chuan-next/package.json chuan-next/yarn.lock ./
RUN yarn install --frozen-lockfile --network-timeout 300000

# 清理构建文件（如果需要）
RUN rm -rf .next out

# 构建前端项目
RUN NEXT_EXPORT=true NODE_ENV=production NEXT_PUBLIC_BACKEND_URL= NEXT_PUBLIC_WS_URL= NEXT_PUBLIC_API_BASE_URL= yarn build

# ==============================================
# 阶段 2：Go 构建阶段
# ==============================================
FROM golang:1.21-alpine AS go-builder

# 安装构建依赖
RUN apk add --no-cache git ca-certificates tzdata

# 设置 Go 环境变量
ENV GOPROXY=https://proxy.golang.org,direct
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64

WORKDIR /app

# 从 GitHub 克隆仓库并进入后端目录
RUN git clone https://github.com/MatrixSeven/file-transfer-go.git /app
WORKDIR /app/file-transfer-go

# 复制 go.mod 和 go.sum 文件，确保依赖能够下载
COPY go.mod go.sum ./
RUN go mod download

# 拷贝前端构建结果
COPY --from=frontend-builder /app/file-transfer-go/chuan-next/out ./internal/web/frontend/

# 复制后端代码并构建 Go 应用
COPY . .
RUN go build -ldflags='-s -w -extldflags "-static"' -o server ./cmd

# ==============================================
# 阶段 3：最终运行镜像
# ==============================================
FROM alpine:3.18

# 安装运行时依赖
RUN apk add --no-cache ca-certificates tzdata && \
    adduser -D -s /bin/sh appuser

WORKDIR /app

# 从构建阶段复制 Go 二进制文件到最终镜像
COPY --from=go-builder --chown=appuser:appuser /app/server ./ 

# 切换到非 root 用户
USER appuser

# 公开端口
EXPOSE 8080

# 启动应用
CMD ["./server"]
