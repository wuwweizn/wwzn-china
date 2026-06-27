ARG BUILD_FROM=alpine:3.20
FROM $BUILD_FROM

COPY rootfs /
COPY hacs/ /hacs/

RUN chmod +x /etc/addon/run

CMD ["/etc/addon/run"]
