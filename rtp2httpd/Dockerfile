ARG BUILD_FROM=ghcr.io/stackia/rtp2httpd:latest
FROM ${BUILD_FROM}

# Home Assistant Add-on 入口脚本
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
