# 第一阶段：从官方镜像提取已编译好的二进制
ARG RTP2HTTPD_VERSION=3.12.2
FROM ghcr.io/stackia/rtp2httpd:${RTP2HTTPD_VERSION} AS rtp2httpd_bin

# 第二阶段：alpine 原生，支持 amd64/arm64/armv7
FROM alpine:3.22

RUN apk add --no-cache bash jq

# 从官方镜像复制静态二进制
COPY --from=rtp2httpd_bin /usr/local/bin/rtp2httpd /usr/local/bin/rtp2httpd

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/bin/bash", "/run.sh"]