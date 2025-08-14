ARG BUILD_FROM
FROM $BUILD_FROM

ARG BUILD_ARCH

RUN apk add --no-cache curl

WORKDIR /opt/alist

RUN case "${BUILD_ARCH}" in \
    amd64)   ALIST_ARCH="alist-linux-amd64.tar.gz" ;; \
    aarch64) ALIST_ARCH="alist-linux-arm64.tar.gz" ;; \
    armv7)   ALIST_ARCH="alist-linux-arm-7.tar.gz" ;; \
    esac \
    && curl -L -o alist.tar.gz "https://github.com/AlistGo/alist/releases/latest/download/${ALIST_ARCH}" \
    && tar zxvf alist.tar.gz \
    && rm -f alist.tar.gz \
    && chmod +x alist

EXPOSE 5244

VOLUME ["/opt/alist/data"]

CMD ["/opt/alist/alist", "server"]