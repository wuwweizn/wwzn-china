ARG BUILD_FROM=v2fly/v2fly-core:v5.24.0
FROM ${BUILD_FROM}

LABEL \
    io.hass.name="V2Ray Core" \
    io.hass.description="V2Ray is a platform for building proxies to bypass network restrictions" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="${VERSION}" \
    maintainer="wuwweizn" \
    org.opencontainers.image.source="https://github.com/wuwweizn/wwzn-china" \
    org.opencontainers.image.licenses="MIT"

RUN apk add --no-cache bash curl jq python3 py3-pip py3-requests py3-yaml

RUN mkdir -p /app
COPY run.sh /app/run.sh
COPY parse_subscription.py /app/parse_subscription.py
RUN chmod +x /app/run.sh
WORKDIR /app

ENTRYPOINT []
CMD ["bash", "/app/run.sh"]
