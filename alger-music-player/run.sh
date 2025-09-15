#!/usr/bin/with-contenv bashio

# 读取配置选项
MUSIC_API_URL=$(bashio::config 'music_api_url' 'http://localhost:3001')
LOG_LEVEL=$(bashio::config 'log_level' 'info')

# 输出配置信息
bashio::log.info "Starting Alger Music Player..."
bashio::log.info "Music API URL: ${MUSIC_API_URL}"
bashio::log.info "Log level: ${LOG_LEVEL}"

# 设置环境变量
export MUSIC_API_URL="${MUSIC_API_URL}"
export LOG_LEVEL="${LOG_LEVEL}"

# 启动应用
bashio::log.info "Starting Alger Music Player application on port 8080..."

# 执行原始容器的启动命令
exec nginx -g 'daemon off;'