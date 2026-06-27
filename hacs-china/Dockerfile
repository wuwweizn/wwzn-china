ARG BUILD_FROM=python:3.12-alpine3.20
FROM $BUILD_FROM

COPY rootfs /
COPY hacs/ /hacs/

RUN tr -d '\r' < /etc/addon/run > /tmp/run_clean \
    && mv /tmp/run_clean /etc/addon/run \
    && chmod a+x /etc/addon/run

CMD ["/etc/addon/run"]
