#!/bin/bash

set -e

echo "🎵 Starting YesPlayMusic..."

# 创建必要目录
mkdir -p /var/log/supervisor /var/log/nginx /run/nginx /var/lib/nginx/tmp

# 设置权限
chown -R nginx:nginx /var/www/html /var/log/nginx /run/nginx /var/lib/nginx

# 检查文件
echo "✅ Web files ready:"
ls -la /var/www/html/

# 测试nginx配置
echo "✅ Testing nginx configuration..."
nginx -t

echo "🚀 Starting services..."

# 启动supervisord
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf