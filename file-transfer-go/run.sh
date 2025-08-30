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

# 实际的可执行文件名是 server
BINARY_NAME="server"

# 检查应用文件
if [ ! -f "/app/${BINARY_NAME}" ]; then
    bashio::log.error "${BINARY_NAME} binary not found!"
    bashio::log.error "Files in /app:"
    ls -la /app/ || true
    exit 1
fi

# 检查文件内容（用于调试）
bashio::log.info "Checking ${BINARY_NAME} binary..."
file /app/${BINARY_NAME} || true

# 确保可执行权限
chmod +x /app/${BINARY_NAME}

# 启动应用
cd /app
bashio::log.info "Starting ${BINARY_NAME} binary..."

# 启动应用
if [ -x "/app/${BINARY_NAME}" ]; then
    exec ./${BINARY_NAME}
else
    bashio::log.error "${BINARY_NAME} is not executable"
    exit 1
fi