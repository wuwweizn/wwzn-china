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
mkdir -p /var/log/supervisor /var/log/nginx /run/nginx /var/lib/nginx/tmp

# 设置正确的权限
chown -R nginx:nginx /var/www/html /var/log/nginx /run/nginx /var/lib/nginx

# 检查关键目录和文件
echo "Checking directories and permissions..."
ls -la /var/www/html/
ls -la /var/log/nginx/
ls -la /run/nginx/

# 配置Nginx
/usr/local/bin/setup_nginx.sh

# 检查nginx配置
echo "Verifying nginx setup..."
nginx -t -c /etc/nginx/nginx.conf

if [ $? -ne 0 ]; then
    echo "❌ Nginx configuration failed, attempting to fix..."
    # 创建超级简化版本
    cat > /etc/nginx/nginx.conf << 'SUPER_SIMPLE_EOF'
events { worker_connections 1024; }
http {
    server {
        listen 80;
        root /var/www/html;
        index index.html;
        location / {
            try_files $uri /index.html;
        }
    }
}
SUPER_SIMPLE_EOF
    nginx -t
fi

# 启动supervisord
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
