#!/usr/bin/with-contenv bashio

# 获取配置选项
SERVER_PORT=$(bashio::config 'server_port')
LOG_LEVEL=$(bashio::config 'log_level')

bashio::log.info "Starting WebTunnel..."
bashio::log.info "Server port: ${SERVER_PORT}"
bashio::log.info "Log level: ${LOG_LEVEL}"

# 设置环境变量
export WEBTUNNEL_PORT="${SERVER_PORT}"
export WEBTUNNEL_LOG_LEVEL="${LOG_LEVEL}"

# 启动 WebTunnel
exec /opt/webtunnel \
  --port="${SERVER_PORT}" \
  --log-level="${LOG_LEVEL}" \
  --config-dir="/data"