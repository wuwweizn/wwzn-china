# =============================================================================
# rootfs/usr/local/bin/run.sh
# =============================================================================
#!/bin/bash

set -e

echo "🎵 Starting YesPlayMusic..."

# 默认配置
NETEASE_API_URL="${NETEASE_API_URL:-https://music-api.hankqin.com}"
SSL="${SSL:-false}"

echo "API URL: ${NETEASE_API_URL}"
echo "SSL enabled: ${SSL}"

# 创建必要的目录并设置权限
mkdir -p /var/log/supervisor /var/log/nginx /run/nginx /var/lib/nginx/tmp
chown -R nginx:nginx /var/www/html /var/log/nginx /run/nginx /var/lib/nginx

# 检查关键文件
echo "Checking web files..."
ls -la /var/www/html/

echo "Checking nginx configuration..."
nginx -t

if [ $? -ne 0 ]; then
    echo "❌ Nginx configuration error, creating minimal config..."
    cat > /etc/nginx/nginx.conf << 'MINIMAL_EOF'
events { worker_connections 1024; }
http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    server {
        listen 80;
        root /var/www/html;
        index index.html;
        
        location / {
            try_files $uri $uri/ /index.html;
        }
        
        location /api/ {
            proxy_pass https://music-api.hankqin.com/;
            proxy_set_header Host music-api.hankqin.com;
            add_header 'Access-Control-Allow-Origin' '*' always;
        }
    }
}
MINIMAL_EOF
    echo "✅ Minimal nginx config created"
    nginx -t
fi

echo "🚀 Starting services..."

# 启动supervisord
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
