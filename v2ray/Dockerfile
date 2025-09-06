ARG BUILD_FROM=v2fly/v2fly-core:v5.24.0
FROM ${BUILD_FROM}

# Home Assistant labels
LABEL \
    io.hass.name="V2Ray Core" \
    io.hass.description="V2Ray is a platform for building proxies to bypass network restrictions" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="${VERSION}" \
    maintainer="wuwweizn" \
    org.opencontainers.image.title="Home Assistant V2Ray Core Add-on" \
    org.opencontainers.image.description="V2Ray is a platform for building proxies to bypass network restrictions" \
    org.opencontainers.image.source="https://github.com/wuwweizn/wwzn-china" \
    org.opencontainers.image.licenses="MIT"

# Install additional packages
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    python3 \
    py3-pip \
    py3-requests \
    py3-yaml

# Create directories
RUN mkdir -p /app

# Copy scripts
COPY run.sh /app/run.sh
COPY parse_subscription.py /app/parse_subscription.py

# Set permissions
RUN chmod +x /app/run.sh

# Set working directory
WORKDIR /app

# Reset entrypoint and set cmd
ENTRYPOINT []
CMD ["bash", "/app/run.sh"]