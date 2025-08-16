ARG BUILD_FROM=alpine:3.21.3
FROM $BUILD_FROM

# Install dependencies
RUN apk add --no-cache \
    bash \
    curl \
    ca-certificates \
    tzdata \
    tini

# Set the working directory
WORKDIR /opt/alist

# Download AList binary
ARG BUILD_ARCH
ARG ALIST_VERSION=v3.41.0

RUN case "${BUILD_ARCH}" in \
    amd64) ARCH="amd64" ;; \
    aarch64) ARCH="arm64" ;; \
    armv7) ARCH="armv7" ;; \
    *) echo "Unsupported architecture: ${BUILD_ARCH}" && exit 1 ;; \
    esac && \
    curl -L -o alist.tar.gz "https://github.com/AlistGo/alist/releases/download/${ALIST_VERSION}/alist-linux-${ARCH}.tar.gz" && \
    tar -xzf alist.tar.gz && \
    rm alist.tar.gz && \
    chmod +x alist

# Create data directory
RUN mkdir -p /data

# Copy startup script
COPY run.sh /usr/bin/run.sh
RUN chmod +x /usr/bin/run.sh

# Set environment variables
ENV PUID=0
ENV PGID=0

# Expose port
EXPOSE 5244

# Use tini as entrypoint
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/bin/run.sh"]