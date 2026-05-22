ARG BUILD_FROM=ghcr.io/home-assistant/base:latest
FROM ${BUILD_FROM}

ARG RTP2HTTPD_VERSION=3.12.1
ARG TARGETARCH

# 根据架构下载对应的 rtp2httpd 静态二进制
RUN set -x \
    && case "${TARGETARCH}" in \
        amd64)   ARCH="x86_64" ;; \
        arm64)   ARCH="aarch64" ;; \
        arm)     ARCH="armv7l" ;; \
        *)       echo "Unsupported arch: ${TARGETARCH}"; exit 1 ;; \
    esac \
    && wget -qO /usr/local/bin/rtp2httpd \
        "https://github.com/stackia/rtp2httpd/releases/download/v${RTP2HTTPD_VERSION}/rtp2httpd-${RTP2HTTPD_VERSION}-${ARCH}" \
    && chmod +x /usr/local/bin/rtp2httpd \
    && rtp2httpd --version || true

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]