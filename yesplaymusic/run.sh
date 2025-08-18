#!/bin/bash
set -e

# 读取Home Assistant配置
CONFIG_PATH="/data/options.json"

# 提取配置值
NETEASE_API_URL=$(jq -r '.netease_api_url // "http://47.121.211.116:3001"' $CONFIG_PATH)
PORT=$(jq -r '.port // 80' $CONFIG_PATH)
SSL=$(jq -r '.ssl // false' $CONFIG_PATH)
CERTFILE=$(jq -r '.certfile // "fullchain.pem"' $CONFIG_PATH)
KEYFILE=$(jq -r '.keyfile // "privkey.pem"' $CONFIG_PATH)

echo "🎵 启动 YesPlayMusic Home Assistant 加载项"
echo "📡 网易云API地址: $NETEASE_API_URL"
echo "🔌 端口: $PORT"
echo "🔒 SSL: $SSL"

# 设置环境变量
export NETEASE_API_URL=$NETEASE_API_URL
export PORT=$PORT
export SSL=$SSL

# 替换nginx配置中的环境变量
envsubst '${NETEASE_API_URL}' < /etc/nginx/nginx.conf > /tmp/nginx.conf
mv /tmp/nginx.conf /etc/nginx/nginx.conf

# 如果启用SSL，检查证书文件
if [ "$SSL" = "true" ]; then
    if [ ! -f "/ssl/$CERTFILE" ] || [ ! -f "/ssl/$KEYFILE" ]; then
        echo "❌ SSL证书文件未找到，回退到HTTP模式"
        SSL="false"
    fi
fi

# 根据SSL配置调整nginx
if [ "$SSL" = "false" ]; then
    # 禁用HTTPS server块
    sed -i '/# HTTPS配置/,$d' /etc/nginx/nginx.conf
fi

# 修改YesPlayMusic的API配置
if [ -f "/usr/share/nginx/html/static/js/app.*.js" ]; then
    # 替换默认API地址为用户配置的地址
    for js_file in /usr/share/nginx/html/static/js/app.*.js; do
        sed -i "s|https://netease-cloud-music-api-[^/]*/|$NETEASE_API_URL/|g" "$js_file"
        sed -i "s|http://localhost:3000|$NETEASE_API_URL|g" "$js_file"
    done
fi

# 创建配置文件用于前端读取API地址
cat > /usr/share/nginx/html/config.json << EOF
{
  "apiUrl": "$NETEASE_API_URL"
}
EOF

echo "✅ 配置完成，启动服务..."

# 启动supervisor
exec /usr/bin/supervisord -c /etc/supervisord.conf