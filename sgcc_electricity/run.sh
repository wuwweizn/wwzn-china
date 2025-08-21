#!/usr/bin/with-contenv bashio
set -e

bashio::log.info "Starting SGCC Electricity service..."

# 默认启动 Python 程序
python3 /usr/src/app/main.py
