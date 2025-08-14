# =============================================================================
# rootfs/usr/local/bin/run.sh
# =============================================================================
#!/usr/bin/env bashio

set -e

# 读取配置
NETEASE_API_URL=$(bashio::config 'netease_api_url')
SSL=$(bashio::config 'ssl')
CERTFILE=$(bashio::config 'certfile')
KEYFILE=$(bashio::config 'keyfile')
CUSTOM_TITLE=$(bashio::config 'custom_title')
LOG_LEVEL=$(bashio::config 'log_level')

# 设置日志级别
bashio::log.level "${LOG_LEVEL}"

bashio::log.info "Starting YesPlayMusic..."
bashio::log.info "API URL: ${NETEASE_API_URL}"

# 设置环境变量
export VUE_APP_NETEASE_API_URL="/api"

# 配置Nginx
/usr/local/bin/setup_nginx.sh

# 启动supervisord
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
