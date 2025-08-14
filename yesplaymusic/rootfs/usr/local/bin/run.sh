# =============================================================================
# rootfs/usr/local/bin/run.sh
# =============================================================================
#!/usr/bin/env bashio

set -e

# 等待bashio库加载
sleep 2

# 读取配置
NETEASE_API_URL=$(bashio::config 'netease_api_url' 'https://music-api.hankqin.com')
SSL=$(bashio::config 'ssl' 'false')
CERTFILE=$(bashio::config 'certfile' 'fullchain.pem')
KEYFILE=$(bashio::config 'keyfile' 'privkey.pem')
CUSTOM_TITLE=$(bashio::config 'custom_title' 'YesPlayMusic')
LOG_LEVEL=$(bashio::config 'log_level' 'info')

# 设置日志级别
bashio::log.level "${LOG_LEVEL}"

bashio::log.info "Starting YesPlayMusic..."
bashio::log.info "API URL: ${NETEASE_API_URL}"

# 设置环境变量
export VUE_APP_NETEASE_API_URL="/api"

# 创建必要的目录
mkdir -p /var/log/supervisor /var/log/nginx /run/nginx

# 配置Nginx
/usr/local/bin/setup_nginx.sh

# 启动supervisord
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf