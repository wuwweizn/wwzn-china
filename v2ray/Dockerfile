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

# Install additional packages if needed
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    python3 \
    py3-pip \
    py3-requests \
    py3-yaml

# Copy scripts
COPY run.sh /usr/local/bin/run.sh
COPY parse_subscription.py /usr/local/bin/parse_subscription.py
RUN chmod +x /usr/local/bin/run.sh /usr/local/bin/parse_subscription.py

# Reset entrypoint and cmd
ENTRYPOINT []
CMD ["/usr/local/bin/run.sh"]