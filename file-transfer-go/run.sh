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

# 检查文件是否存在和可执行
if [ ! -f "/app/file-transfer-go" ]; then
    bashio::log.error "file-transfer-go binary not found!"
    exit 1
fi

if [ ! -x "/app/file-transfer-go" ]; then
    bashio::log.error "file-transfer-go binary is not executable!"
    chmod +x /app/file-transfer-go
fi

# 启动应用
cd /app
bashio::log.info "Starting file-transfer-go binary..."
exec ./file-transfer-go