#!/bin/bash
set -e

# Home Assistant Add-on 环境初始化
source /usr/lib/hassio-addons/base.sh

# 获取配置并设置环境变量
MUSIC_API_URL=$(bashio::config 'music_api_url' 'http://localhost:3001')
LOG_LEVEL=$(bashio::config 'log_level' 'info')

export MUSIC_API_URL="${MUSIC_API_URL}"
export LOG_LEVEL="${LOG_LEVEL}"

bashio::log.info "==================================="
bashio::log.info "🎵 Alger Music Player Add-on"
bashio::log.info "==================================="
bashio::log.info "Music API URL: ${MUSIC_API_URL}"
bashio::log.info "Log Level: ${LOG_LEVEL}"

# 创建必要的目录
mkdir -p /var/log/nginx
mkdir -p /run/nginx

# 设置权限
chown -R nginx:nginx /var/log/nginx /run/nginx

# 启动服务
bashio::log.info "Starting services..."

# 启动 UnblockNeteaseMusic
/etc/services.d/unm/run &
UNM_PID=$!

# 等待一下确保 UNM 启动
sleep 5

# 启动 Alger Music Player（包含 nginx）
exec /etc/services.d/alger-music/run