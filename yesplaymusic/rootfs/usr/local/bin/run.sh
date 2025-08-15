# =============================================================================
# rootfs/usr/local/bin/run.sh
# =============================================================================
#!/bin/bash

set -e

echo "Starting YesPlayMusic..."

# 默认配置
NETEASE_API_URL="${NETEASE_API_URL:-https://music-api.hankqin.com}"
SSL="${SSL:-false}"
CERTFILE="${CERTFILE:-fullchain.pem}"
KEYFILE="${KEYFILE:-privkey.pem}"
CUSTOM_TITLE="${CUSTOM_TITLE:-YesPlayMusic}"

echo "API URL: ${NETEASE_API_URL}"
echo "SSL enabled: ${SSL}"

# 导出变量供nginx配置使用
export NETEASE_API_URL SSL CERTFILE KEYFILE CUSTOM_TITLE

# 创建必要的目录
mkdir -p /var/log/supervisor /var/log/nginx /run/nginx

# 配置Nginx
/usr/local/bin/setup_nginx.sh

# 启动supervisord
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
