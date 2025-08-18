#!/bin/sh

# 如果 HA 提供了 options.api_url，就会注入到 API_URL 环境变量里
API=${API_URL:-http://47.121.211.116:3001}

echo "➡️ Using API URL: $API"

# 替换 nginx 配置模板中的 __API_URL__
sed "s|__API_URL__|$API|g" /etc/nginx/templates/nginx.conf.template > /etc/nginx/conf.d/default.conf

# 启动 nginx
nginx -g "daemon off;"
