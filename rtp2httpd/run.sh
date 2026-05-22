#!/bin/bash
set -e

log_info()  { echo "[$(date '+%H:%M:%S')] INFO: $*"; }
log_warn()  { echo "[$(date '+%H:%M:%S')] WARN: $*"; }

OPTIONS="/data/options.json"

log_info "========================================="
log_info "  rtp2httpd 启动中..."
log_info "========================================="

# 读取配置（从 HA Supervisor 注入的 /data/options.json）
LISTEN_PORT=$(jq -r '.listen_port // 5140' "$OPTIONS")
MAX_CLIENTS=$(jq -r '.max_clients // 20' "$OPTIONS")
VERBOSE=$(jq -r '.verbose // 2' "$OPTIONS")
WORKERS=$(jq -r '.workers // 1' "$OPTIONS")
UPSTREAM_INTERFACE=$(jq -r '.upstream_interface // ""' "$OPTIONS")
EXTERNAL_M3U=$(jq -r '.external_m3u // ""' "$OPTIONS")
EXTERNAL_M3U_UPDATE_INTERVAL=$(jq -r '.external_m3u_update_interval // 7200' "$OPTIONS")
FCC_PORT_RANGE=$(jq -r '.fcc_listen_port_range // ""' "$OPTIONS")
R2H_TOKEN=$(jq -r '.r2h_token // ""' "$OPTIONS")
EXTRA_ARGS=$(jq -r '.extra_args // ""' "$OPTIONS")

log_info "监听端口:     ${LISTEN_PORT}"
log_info "最大客户端数: ${MAX_CLIENTS}"
log_info "工作进程数:   ${WORKERS}"
log_info "日志级别:     ${VERBOSE}"

# 配置文件优先（addon_config 挂载到 /config）
CONFIG_FILE="/config/rtp2httpd.conf"
if [ -f "${CONFIG_FILE}" ]; then
    log_info "发现配置文件 ${CONFIG_FILE}，使用配置文件模式启动"
    exec /usr/local/bin/rtp2httpd \
        --config "${CONFIG_FILE}" \
        ${EXTRA_ARGS}
fi

log_info "使用加载项选项参数模式启动"

ARGS="--noconfig"
ARGS="${ARGS} --listen ${LISTEN_PORT}"
ARGS="${ARGS} --maxclients ${MAX_CLIENTS}"
ARGS="${ARGS} --verbose ${VERBOSE}"
ARGS="${ARGS} --workers ${WORKERS}"

if [ -n "${UPSTREAM_INTERFACE}" ]; then
    log_info "上游接口: ${UPSTREAM_INTERFACE}"
    ARGS="${ARGS} --upstream-interface ${UPSTREAM_INTERFACE}"
fi

if [ -n "${EXTERNAL_M3U}" ]; then
    log_info "外部 M3U: ${EXTERNAL_M3U}"
    ARGS="${ARGS} --external-m3u ${EXTERNAL_M3U}"
    ARGS="${ARGS} --external-m3u-update-interval ${EXTERNAL_M3U_UPDATE_INTERVAL}"
fi

if [ -n "${FCC_PORT_RANGE}" ]; then
    log_info "FCC 端口范围: ${FCC_PORT_RANGE}"
    ARGS="${ARGS} --fcc-listen-port-range ${FCC_PORT_RANGE}"
fi

if [ -n "${R2H_TOKEN}" ]; then
    log_info "已启用 r2h-token 访问认证"
    ARGS="${ARGS} --r2h-token ${R2H_TOKEN}"
fi

if [ -n "${EXTRA_ARGS}" ]; then
    log_info "额外参数: ${EXTRA_ARGS}"
    ARGS="${ARGS} ${EXTRA_ARGS}"
fi

log_info "启动命令: rtp2httpd ${ARGS}"
exec /usr/local/bin/rtp2httpd ${ARGS}