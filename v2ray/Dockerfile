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
    jq

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]