#!/usr/bin/with-contenv bashio

# 从 Home Assistant 配置中读取选项
PORT=$(bashio::config 'port')
NODE_ENV=$(bashio::config 'node_env')
LOG_LEVEL=$(bashio::config 'log_level')

# 设置环境变量
export PORT=${PORT}
export NODE_ENV=${NODE_ENV}
export LOG_LEVEL=${LOG_LEVEL}

bashio::log.info "Starting File Transfer Go..."
bashio::log.info "Port: ${PORT}"
bashio::log.info "Environment: ${NODE_ENV}"
bashio::log.info "Log Level: ${LOG_LEVEL}"

# 启动应用
cd /app
exec ./file-transfer-go