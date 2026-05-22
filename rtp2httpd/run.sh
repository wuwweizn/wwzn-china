#!/usr/bin/with-contenv bashio

bashio::log.info "========================================="
bashio::log.info "  rtp2httpd 启动中..."
bashio::log.info "========================================="

# 读取加载项配置
LISTEN_PORT=$(bashio::config 'listen_port')
MAX_CLIENTS=$(bashio::config 'max_clients')
VERBOSE=$(bashio::config 'verbose')
WORKERS=$(bashio::config 'workers')
UPSTREAM_INTERFACE=$(bashio::config 'upstream_interface')
EXTERNAL_M3U=$(bashio::config 'external_m3u')
EXTERNAL_M3U_UPDATE_INTERVAL=$(bashio::config 'external_m3u_update_interval')
FCC_PORT_RANGE=$(bashio::config 'fcc_listen_port_range')
R2H_TOKEN=$(bashio::config 'r2h_token')
EXTRA_ARGS=$(bashio::config 'extra_args')

bashio::log.info "监听端口:       ${LISTEN_PORT}"
bashio::log.info "最大客户端数:   ${MAX_CLIENTS}"
bashio::log.info "工作进程数:     ${WORKERS}"
bashio::log.info "日志级别:       ${VERBOSE}"

# 如果存在配置文件则直接使用配置文件启动，忽略下方所有参数
CONFIG_FILE="/config/rtp2httpd.conf"
if bashio::fs.file_exists "${CONFIG_FILE}"; then
    bashio::log.info "发现配置文件 ${CONFIG_FILE}，使用配置文件模式启动"
    exec /usr/local/bin/rtp2httpd \
        --config "${CONFIG_FILE}" \
        ${EXTRA_ARGS}
fi

# 无配置文件，用加载项选项拼装参数
bashio::log.info "使用加载项选项参数模式启动"

ARGS="--noconfig"
ARGS="${ARGS} --listen ${LISTEN_PORT}"
ARGS="${ARGS} --maxclients ${MAX_CLIENTS}"
ARGS="${ARGS} --verbose ${VERBOSE}"
ARGS="${ARGS} --workers ${WORKERS}"

# 上游网络接口（可选）
if [ -n "${UPSTREAM_INTERFACE}" ]; then
    bashio::log.info "上游接口: ${UPSTREAM_INTERFACE}"
    ARGS="${ARGS} --upstream-interface ${UPSTREAM_INTERFACE}"
fi

# 外部 M3U 播放列表（可选）
if [ -n "${EXTERNAL_M3U}" ]; then
    bashio::log.info "外部 M3U: ${EXTERNAL_M3U}"
    ARGS="${ARGS} --external-m3u ${EXTERNAL_M3U}"
    ARGS="${ARGS} --external-m3u-update-interval ${EXTERNAL_M3U_UPDATE_INTERVAL}"
fi

# FCC 端口范围（可选）
if [ -n "${FCC_PORT_RANGE}" ]; then
    bashio::log.info "FCC 端口范围: ${FCC_PORT_RANGE}"
    ARGS="${ARGS} --fcc-listen-port-range ${FCC_PORT_RANGE}"
fi

# 访问令牌（可选）
if [ -n "${R2H_TOKEN}" ]; then
    bashio::log.info "已启用 r2h-token 访问认证"
    ARGS="${ARGS} --r2h-token ${R2H_TOKEN}"
fi

# 额外自定义参数
if [ -n "${EXTRA_ARGS}" ]; then
    bashio::log.info "额外参数: ${EXTRA_ARGS}"
    ARGS="${ARGS} ${EXTRA_ARGS}"
fi

bashio::log.info "启动命令: rtp2httpd ${ARGS}"
exec /usr/local/bin/rtp2httpd ${ARGS}
