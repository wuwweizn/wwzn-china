ARG BUILD_FROM
FROM $BUILD_FROM

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY rootfs /
COPY hacs/ /hacs/

RUN tr -d '\r' < /etc/addon/run > /tmp/run_clean \
    && mv /tmp/run_clean /etc/addon/run \
    && chmod a+x /etc/addon/run
