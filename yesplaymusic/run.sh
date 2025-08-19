#!/bin/bash
set -e

# 读取Home Assistant配置
CONFIG_PATH="/data/options.json"

echo "🎵 启动 YesPlayMusic Home Assistant 加载项"

# 检查配置文件是否存在
if [ ! -f "$CONFIG_PATH" ]; then
    echo "⚠️ 配置文件不存在，使用默认配置"
    NETEASE_API_URL="http://47.121.211.116:3001"
    PORT="80"
    SSL="false"
    CERTFILE="fullchain.pem"
    KEYFILE="privkey.pem"
else
    # 提取配置值
    NETEASE_API_URL=$(jq -r '.netease_api_url // "http://47.121.211.116:3001"' $CONFIG_PATH)
    PORT=$(jq -r '.port // 80' $CONFIG_PATH)
    SSL=$(jq -r '.ssl // false' $CONFIG_PATH)
    CERTFILE=$(jq -r '.certfile // "fullchain.pem"' $CONFIG_PATH)
    KEYFILE=$(jq -r '.keyfile // "privkey.pem"' $CONFIG_PATH)
fi

echo "📡 网易云API地址: $NETEASE_API_URL"
echo "🔌 端口: $PORT"
echo "🔒 SSL: $SSL"

# 设置环境变量
export NETEASE_API_URL=$NETEASE_API_URL
export PORT=$PORT
export SSL=$SSL

# 验证静态文件
if [ ! -f "/usr/share/nginx/html/index.html" ]; then
    echo "❌ 静态文件不存在，创建默认页面"
    cat > /usr/share/nginx/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>YesPlayMusic</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <style>
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0; 
            padding: 0; 
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container { 
            background: white;
            border-radius: 15px;
            padding: 40px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 500px;
        }
        h1 { color: #333; margin-bottom: 20px; }
        .loading { color: #667eea; margin: 20px 0; }
        .info { color: #666; margin: 15px 0; }
        .button { 
            display: inline-block; 
            padding: 12px 25px; 
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white; 
            text-decoration: none; 
            border-radius: 25px; 
            margin: 10px;
            transition: transform 0.2s;
        }
        .button:hover { transform: translateY(-2px); }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        .spinner {
            border: 3px solid #f3f3f3;
            border-top: 3px solid #667eea;
            border-radius: 50%;
            width: 30px;
            height: 30px;
            animation: spin 1s linear infinite;
            margin: 20px auto;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎵 YesPlayMusic</h1>
        <div class="spinner"></div>
        <p class="loading">正在初始化服务...</p>
        <p class="info">如果长时间无法加载，可能的原因：</p>
        <ul style="text-align: left;">
            <li>网易云API服务正在启动</li>
            <li>网络连接检查中</li>
            <li>静态资源加载中</li>
        </ul>
        <a href="javascript:location.reload()" class="button">🔄 刷新页面</a>
        <a href="/api/" class="button" target="_blank">🔧 检查API</a>
    </div>
    <script>
        let retryCount = 0;
        const maxRetries = 10;
        
        function checkStatus() {
            retryCount++;
            if (retryCount <= maxRetries) {
                setTimeout(() => {
                    location.reload();
                }, 3000);
            }
        }
        
        checkStatus();
    </script>
</body>
</html>
EOF
fi

# 替换nginx配置中的环境变量
if [ -f "/etc/nginx/nginx.conf" ]; then
    envsubst '${NETEASE_API_URL}' < /etc/nginx/nginx.conf > /tmp/nginx.conf
    mv /tmp/nginx.conf /etc/nginx/nginx.conf
else
    echo "❌ Nginx配置文件不存在"
    exit 1
fi

# 如果启用SSL，检查证书文件
if [ "$SSL" = "true" ]; then
    if [ ! -f "/ssl/$CERTFILE" ] || [ ! -f "/ssl/$KEYFILE" ]; then
        echo "⚠️ SSL证书文件未找到，回退到HTTP模式"
        SSL="false"
    fi
fi

# 根据SSL配置调整nginx
if [ "$SSL" = "false" ]; then
    # 禁用HTTPS server块
    sed -i '/# HTTPS配置/,$d' /etc/nginx/nginx.conf
fi

# 测试nginx配置
nginx -t || (echo "❌ Nginx配置测试失败" && exit 1)

# 创建配置文件用于前端读取API地址
mkdir -p /usr/share/nginx/html
cat > /usr/share/nginx/html/config.json << EOF
{
  "apiUrl": "$NETEASE_API_URL",
  "version": "1.0.0",
  "timestamp": "$(date -Iseconds)"
}
EOF

echo "✅ 配置完成，启动服务..."

# 启动supervisor
exec /usr/bin/supervisord -c /etc/supervisord.conf