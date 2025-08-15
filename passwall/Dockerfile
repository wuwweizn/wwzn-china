ARG BUILD_ARCH
FROM openwrtorg/rootfs:x86-64 AS builder
# 如果是多架构，需要替换为对应 rootfs
# amd64 -> x86-64
# aarch64 -> arm64
# armv7 -> armvirt

RUN opkg update && \
    opkg install luci-app-passwall passwall

FROM scratch
COPY --from=builder / /
COPY run.sh /run.sh
RUN chmod +x /run.sh
CMD ["/run.sh"]
