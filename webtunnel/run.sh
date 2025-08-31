#!/usr/bin/with-contenv bashio

# 获取配置选项
SERVER_PORT=$(bashio::config 'server_port')
LOG_LEVEL=$(bashio::config 'log_level')

bashio::log.info "Starting WebTunnel..."
bashio::log.info "Server port: ${SERVER_PORT}"
bashio::log.info "Log level: ${LOG_LEVEL}"

# 查找 WebTunnel 可执行文件
WEBTUNNEL_BIN=""
if [ -f /opt/webtunnel ]; then
    WEBTUNNEL_BIN="/opt/webtunnel"
elif [ -f /opt/webtunnel_* ]; then
    WEBTUNNEL_BIN=$(find /opt -name "webtunnel*" -type f -executable | head -1)
else
    bashio::log.error "WebTunnel binary not found!"
    exit 1
fi

bashio::log.info "Using WebTunnel binary: ${WEBTUNNEL_BIN}"

# 设置环境变量
export WEBTUNNEL_PORT="${SERVER_PORT}"
export WEBTUNNEL_LOG_LEVEL="${LOG_LEVEL}"

# 启动 WebTunnel（根据实际的命令行参数调整）
exec "${WEBTUNNEL_BIN}" \
  --port="${SERVER_PORT}" \
  --log-level="${LOG_LEVEL}" \
  --config-dir="/data"