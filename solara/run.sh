#!/usr/bin/with-contenv bashio

# 获取日志级别配置
LOG_LEVEL=$(bashio::config 'log_level')
bashio::log.info "Starting Solara Music Player with log level: ${LOG_LEVEL}"

# 确保数据目录存在
mkdir -p /config/solara /share/solara /media

# 如果配置目录有自定义文件，使用配置目录的文件
if [ -d "/config/solara" ] && [ -n "$(ls -A /config/solara 2>/dev/null)" ]; then
    bashio::log.info "Using custom configuration from /config/solara"
    rm -rf /var/www/html/*
    cp -r /config/solara/* /var/www/html/
else
    bashio::log.info "Using default Solara files"
    # 如果配置目录为空，将默认文件复制到配置目录作为备份
    if [ -d "/config/solara" ] && [ -z "$(ls -A /config/solara 2>/dev/null)" ]; then
        bashio::log.info "Backing up default files to /config/solara"
        cp -r /var/www/html/* /config/solara/
    fi
fi

# 启动 nginx
bashio::log.info "Starting Nginx on port 3100"

exec nginx -g "daemon off;"