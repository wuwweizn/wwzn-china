ARG BUILD_FROM
FROM ${BUILD_FROM}

# 安装依赖
RUN apk add --no-cache bash curl tzdata ca-certificates

# 从官方镜像复制文件
COPY --from=matrixseven/file-transfer-go:latest /app /app

COPY run.sh /
RUN chmod a+x /run.sh

WORKDIR /app
EXPOSE 8080
CMD [ "/run.sh" ]