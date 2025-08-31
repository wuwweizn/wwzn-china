FROM alpine:3.21.2
ARG TARGETPLATFORM

RUN apk add --no-cache wget tar libstdc++ libgcc libc6-compat
WORKDIR /tmp

RUN echo "TARGETPLATFORM=$TARGETPLATFORM" && \
    case "$TARGETPLATFORM" in \
      linux/amd64) wget -O WebTunnelCore.tar.gz https://w.pgrm.top/download/linux/WebTunnelCore-linux-x64-250612.tar.gz ;; \
      linux/arm64) wget -O WebTunnelCore.tar.gz https://w.pgrm.top/download/linux/WebTunnelCore-linux-arm64-250612.tar.gz ;; \
      *) echo "Unsupported platform $TARGETPLATFORM" && exit 1 ;; \
    esac && \
    tar -xzvf WebTunnelCore.tar.gz -C / && \
    chmod +x "/WebTunnelCore" && \
    rm -rf /tmp/*

ENTRYPOINT ["/WebTunnelCore", "--config=/data/.webtunnel"]
