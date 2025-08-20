ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="wuwweizn" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Home Assistant Community Add-ons" \
    org.opencontainers.image.authors="wuwweizn" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/wuwweizn/wwzn-china" \
    org.opencontainers.image.source="https://github.com/stark81/my_yesplaymusic" \
    org.opencontainers.image.documentation="https://github.com/wuwweizn/wwzn-china/blob/main/yesplaymusic/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

# Environment variables
ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    NODE_ENV=production

# Install additional dependencies needed for YesPlayMusic
RUN apk update && apk add --no-cache \
    git \
    python3 \
    py3-pip \
    make \
    g++ \
    curl \
    && rm -rf /var/cache/apk/*

# Set working directory
WORKDIR /app

# Clone YesPlayMusic repository and install dependencies
RUN \
    git clone --depth 1 https://github.com/stark81/my_yesplaymusic.git /tmp/yesplaymusic \
    && cp -r /tmp/yesplaymusic/* /app/ \
    && rm -rf /tmp/yesplaymusic \
    && npm install -g pnpm \
    && pnpm config set registry https://registry.npmmirror.com \
    && pnpm install --frozen-lockfile \
    && pnpm run build \
    && rm -rf node_modules \
    && npm install express http-proxy-middleware \
    && npm cache clean --force

# Copy server script
COPY rootfs/app/server.js /app/server.js

# Copy root filesystem
COPY rootfs /

# Create necessary directories and set permissions
RUN \
    mkdir -p /data/settings \
    && mkdir -p /app/dist \
    && chmod +x /etc/s6-overlay/s6-rc.d/yesplaymusic/run

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1