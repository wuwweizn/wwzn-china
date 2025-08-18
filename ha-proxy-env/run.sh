#!/usr/bin/with-contenv bashio
set -e

HTTP_PROXY=$(bashio::config 'http_proxy')
HTTPS_PROXY=$(bashio::config 'https_proxy')

# 写入环境变量
echo "export HTTP_PROXY=$HTTP_PROXY" > /etc/profile.d/proxy.sh
echo "export HTTPS_PROXY=$HTTPS_PROXY" >> /etc/profile.d/proxy.sh
echo "HTTP_PROXY=$HTTP_PROXY" >> /etc/environment
echo "HTTPS_PROXY=$HTTPS_PROXY" >> /etc/environment

bashio::log.info "已设置代理:"
bashio::log.info "HTTP_PROXY=$HTTP_PROXY"
bashio::log.info "HTTPS_PROXY=$HTTPS_PROXY"

# 启动 Nginx，提供 WebUI
nginx -g "daemon off;"
