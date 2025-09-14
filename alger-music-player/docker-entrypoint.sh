#!/bin/bash
set -e

echo "🎵 Initializing Alger Music Player Add-on..."

# 检查并下载原始应用（如果不存在）
if [ ! -f "/app/server.js" ]; then
    echo "📥 Downloading Alger Music Player application..."
    
    # 使用 wget 下载并解压（假设有可用的下载链接）
    # 或者直接从 Docker Hub 镜像中提取
    cd /tmp
    
    # 这里我们需要一个替代方案来获取原始应用文件
    # 方案1：如果原项目提供了发布包
    # wget -O alger-app.tar.gz "https://github.com/algerkong/AlgerMusicPlayer/archive/refs/heads/main.tar.gz"
    # tar -xzf alger-app.tar.gz --strip-components=1 -C /app
    
    # 方案2：从现有的 Docker 镜像提取（推荐）
    echo "⚠️  Warning: Alger Music Player files not found."
    echo "Please ensure the application files are properly copied to /app"
    
    # 创建一个基本的服务器文件作为回退
    cat > /app/server.js << 'EOF'
const express = require('express');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.static('/app/dist'));

app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', message: 'Alger Music Player API is running' });
});

app.get('*', (req, res) => {
    res.sendFile(path.join('/app/dist', 'index.html'));
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Alger Music Player backend running on port ${PORT}`);
});
EOF
    
    # 创建基本的前端文件
    mkdir -p /app/dist
    cat > /app/dist/index.html << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Alger Music Player</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
        }
        .container {
            background: rgba(255,255,255,0.1);
            padding: 40px;
            border-radius: 20px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
        }
        h1 { margin-bottom: 20px; }
        .status {
            padding: 10px 20px;
            border-radius: 10px;
            background: rgba(255,255,255,0.2);
            margin: 20px 0;
        }
        .loading {
            animation: pulse 2s infinite;
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎵 Alger Music Player</h1>
        <div class="status loading">
            正在初始化音乐服务...
        </div>
        <p>UnblockNeteaseMusic 服务已启动</p>
        <p>请稍等片刻，系统正在加载完整的音乐播放器</p>
    </div>
    
    <script>
        // 检查服务状态
        async function checkServices() {
            try {
                const response = await fetch('/api/health');
                if (response.ok) {
                    document.querySelector('.status').innerHTML = '✅ 服务运行正常';
                    document.querySelector('.status').classList.remove('loading');
                }
            } catch (error) {
                setTimeout(checkServices, 2000);
            }
        }
        
        // 定期检查服务状态
        checkServices();
        setInterval(checkServices, 5000);
    </script>
</body>
</html>
EOF

    # 如果没有 package.json，创建一个基本的
    if [ ! -f "/app/package.json" ]; then
        cat > /app/package.json << 'EOF'
{
  "name": "alger-music-player",
  "version": "1.0.0",
  "description": "Alger Music Player with UnblockNeteaseMusic",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.0"
  },
  "scripts": {
    "start": "node server.js"
  }
}
EOF
        cd /app && npm install --production
    fi
fi

# 验证 UnblockNeteaseMusic
if [ ! -f "/opt/unm/app.js" ]; then
    echo "❌ UnblockNeteaseMusic not found!"
    exit 1
fi

echo "✅ All services initialized"

# 设置权限
chown -R app:app /app
chown -R nginx:nginx /var/log/nginx /run/nginx

echo "🚀 Starting services with supervisor..."

# 启动 supervisor
exec /usr/bin/supervisord -c /etc/supervisor.d/supervisord.conf