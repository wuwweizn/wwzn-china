ARG BUILD_FROM
FROM ${BUILD_FROM}

# 设置环境变量
ENV LANG=C.UTF-8

# 安装必要的依赖
RUN apk add --no-cache \
    bash \
    curl \
    tzdata \
    ca-certificates

# 设置工作目录
WORKDIR /app

# 从官方镜像复制应用文件
COPY --from=matrixseven/file-transfer-go:latest /app /app

# 复制启动脚本
COPY run.sh /
RUN chmod a+x /run.sh

# 确保应用文件有执行权限
RUN chmod +x /app/file-transfer-go 2>/dev/null || true

# 暴露端口
EXPOSE 8080

# 启动脚本
CMD [ "/run.sh" ]