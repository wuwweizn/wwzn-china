ARG BUILD_FROM=ghcr.io/hassio-addons/base:16.0.1
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

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

# Install Node.js and dependencies
RUN \
    set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        gnupg \
        build-essential \
        python3 \
        python3-dev \
        python3-pip \
        git \
        libasound2-dev \
        libgconf-2-4 \
        libxss1 \
        libgtk-3-0 \
        libxrandr2 \
        libasound2 \
        libpangocairo-1.0-0 \
        libatk1.0-0 \
        libcairo-gobject2 \
        libgtk-3-0 \
        libgdk-pixbuf2.0-0 \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g pnpm \
    && apt-get purge -y --auto-remove \
        curl \
        gnupg \
        build-essential \
        python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set working directory
WORKDIR /app

# Clone YesPlayMusic repository
RUN \
    git clone https://github.com/stark81/my_yesplaymusic.git /tmp/yesplaymusic \
    && cp -r /tmp/yesplaymusic/* /app/ \
    && rm -rf /tmp/yesplaymusic

# Install dependencies and build
RUN \
    pnpm install --frozen-lockfile \
    && pnpm run build \
    && rm -rf node_modules \
    && pnpm install --prod --frozen-lockfile

# Copy root filesystem
COPY rootfs /

# Create app user
RUN \
    groupadd -r yesplaymusic \
    && useradd -r -g yesplaymusic -s /bin/bash -c "YesPlayMusic user" yesplaymusic \
    && chown -R yesplaymusic:yesplaymusic /app

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Set entrypoint
ENTRYPOINT ["/init"]