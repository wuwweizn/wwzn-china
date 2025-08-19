#!/bin/sh

# 从 HA options.json 读取 netease_api_url
API_URL=$(jq --raw-output '.netease_api_url // "http://47.121.211.116:3001"' /data/options.json)

# 替换模板中的占位符
sed "s|__API_URL__|${API_URL}|g" /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

# 执行传入的命令（通常是 Nginx）
exec "$@"