# 第一阶段：从官方镜像提取已编译好的二进制
ARG RTP2HTTPD_VERSION=3.12.1
FROM ghcr.io/stackia/rtp2httpd:${RTP2HTTPD_VERSION} AS rtp2httpd_bin

# 第二阶段：基于 HA base 镜像（含 bashio/s6），仅复制二进制
FROM ghcr.io/home-assistant/base:latest

# 从官方镜像复制已编译好的静态二进制（Alpine musl，无依赖）
COPY --from=rtp2httpd_bin /usr/local/bin/rtp2httpd /usr/local/bin/rtp2httpd

# 复制启动脚本
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
