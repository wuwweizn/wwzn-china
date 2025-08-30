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

# 检查应用文件
if [ ! -f "/app/file-transfer-go" ]; then
    bashio::log.error "file-transfer-go binary not found!"
    bashio::log.error "Files in /app:"
    ls -la /app/ || true
    exit 1
fi

# 检查文件内容（用于调试）
bashio::log.info "Checking file-transfer-go binary..."
file /app/file-transfer-go || true
head -c 50 /app/file-transfer-go || true

# 确保可执行权限
chmod +x /app/file-transfer-go

# 启动应用
cd /app
bashio::log.info "Starting file-transfer-go binary..."

# 如果直接启动失败，尝试其他方式
if [ -x "/app/file-transfer-go" ]; then
    exec ./file-transfer-go
else
    bashio::log.error "file-transfer-go is not executable"
    exit 1
fi