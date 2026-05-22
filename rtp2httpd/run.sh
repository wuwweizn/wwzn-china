#!/usr/bin/with-contenv bashio

# 读取 HA 配置
LISTEN_PORT=$(bashio::config 'listen_port')
MAX_CLIENTS=$(bashio::config 'max_clients')
VERBOSE=$(bashio::config 'verbose')
EXTRA_ARGS=$(bashio::config 'extra_args')

bashio::log.info "Starting rtp2httpd on port ${LISTEN_PORT}..."
bashio::log.info "Max clients: ${MAX_CLIENTS}, Verbose level: ${VERBOSE}"

# 检查是否有挂载的配置文件
if bashio::fs.file_exists "/config/rtp2httpd.conf"; then
    bashio::log.info "Using config file: /config/rtp2httpd.conf"
    exec /usr/local/bin/rtp2httpd \
        --config /config/rtp2httpd.conf \
        ${EXTRA_ARGS}
else
    bashio::log.info "No config file found, using command line arguments"
    exec /usr/local/bin/rtp2httpd \
        --noconfig \
        --verbose "${VERBOSE}" \
        --listen "${LISTEN_PORT}" \
        --maxclients "${MAX_CLIENTS}" \
        ${EXTRA_ARGS}
fi
