#!/usr/bin/with-contenv bashio

bashio::log.info "========================================="
bashio::log.info "  rtp2httpd 启动中..."
bashio::log.info "========================================="

# 读取加载项配置
LISTEN_PORT=$(bashio::config 'listen_port')
MAX_CLIENTS=$(bashio::config 'max_clients')
VERBOSE=$(bashio::config 'verbose')
EXTRA_ARGS=$(bashio::config 'extra_args')

bashio::log.info "监听端口: ${LISTEN_PORT}"
bashio::log.info "最大客户端数: ${MAX_CLIENTS}"
bashio::log.info "日志级别: ${VERBOSE}"

# 检查用户是否在 addon_config 目录放了配置文件
CONFIG_FILE="/config/rtp2httpd.conf"

if bashio::fs.file_exists "${CONFIG_FILE}"; then
    bashio::log.info "发现配置文件: ${CONFIG_FILE}，使用配置文件模式启动"
    exec /usr/local/bin/rtp2httpd \
        --config "${CONFIG_FILE}" \
        ${EXTRA_ARGS}
else
    bashio::log.info "未发现配置文件，使用参数模式启动"
    bashio::log.info "提示: 可在 /addon_configs/rtp2httpd/ 目录下放置 rtp2httpd.conf 以使用配置文件"
    exec /usr/local/bin/rtp2httpd \
        --noconfig \
        --verbose "${VERBOSE}" \
        --listen "${LISTEN_PORT}" \
        --maxclients "${MAX_CLIENTS}" \
        ${EXTRA_ARGS}
fi