# Complete standalone solution
FROM node:18-alpine

WORKDIR /app

# Install system dependencies
RUN apk add --no-cache curl bash git

# Create package.json with only essential dependencies
RUN cat > package.json << 'EOF'
{
  "name": "yesplaymusic-server",
  "version": "1.0.0",
  "description": "YesPlayMusic Home Assistant Addon",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

# Install only essential dependencies
RUN npm install

# Create standalone server that doesn't depend on the original app
RUN cat > server.js << 'EOF'
const express = require('express');
const http = require('http');
const https = require('https');
const fs = require('fs');
const path = require('path');

const app = express();

// Get environment variables with defaults
const port = process.env.PORT || 8080;
const host = process.env.HOST || '0.0.0.0';
const apiUrl = process.env.VUE_APP_NETEASE_API_URL || 'http://47.121.211.116:3001';

console.log('=== YesPlayMusic Container Started ===');
console.log('Host:', host);
console.log('Port:', port);
console.log('API URL:', apiUrl);
console.log('=====================================');

// Enable CORS for all routes
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS, PATCH');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization, Cookie');
  res.header('Access-Control-Allow-Credentials', 'true');
  
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    config: { host, port, apiUrl }
  });
});

// API proxy endpoint
app.use('/api', (req, res) => {
  const targetUrl = apiUrl + req.url;
  console.log(`[${new Date().toISOString()}] Proxy: ${req.method} ${req.url} -> ${targetUrl}`);
  
  const protocol = targetUrl.startsWith('https:') ? https : http;
  
  const options = {
    method: req.method,
    headers: {
      ...req.headers,
      'host': new URL(apiUrl).hostname,
      'origin': apiUrl,
      'referer': apiUrl
    },
    timeout: 10000
  };
  
  // Remove hop-by-hop headers
  delete options.headers.connection;
  delete options.headers['keep-alive'];
  delete options.headers['proxy-authenticate'];
  delete options.headers['proxy-authorization'];
  delete options.headers.te;
  delete options.headers.trailers;
  delete options.headers.upgrade;
  
  const proxyReq = protocol.request(targetUrl, options, (proxyRes) => {
    // Set status code
    res.statusCode = proxyRes.statusCode;
    
    // Copy headers
    Object.keys(proxyRes.headers).forEach(key => {
      if (key.toLowerCase() !== 'transfer-encoding') {
        res.setHeader(key, proxyRes.headers[key]);
      }
    });
    
    // Enable CORS
    res.setHeader('Access-Control-Allow-Origin', '*');
    
    // Pipe response
    proxyRes.pipe(res);
  });
  
  proxyReq.on('error', (err) => {
    console.error('Proxy error:', err.message);
    if (!res.headersSent) {
      res.status(500).json({ 
        error: 'API proxy error', 
        message: err.message,
        target: targetUrl
      });
    }
  });
  
  proxyReq.on('timeout', () => {
    console.error('Proxy timeout:', targetUrl);
    if (!res.headersSent) {
      res.status(504).json({ error: 'API timeout' });
    }
    proxyReq.destroy();
  });
  
  // Pipe request body
  req.pipe(proxyReq);
});

// Serve static files if they exist
const distPath = path.join(__dirname, 'dist');
app.use(express.static(distPath));

// Main route - serve app or status page
app.get('*', (req, res) => {
  const indexPath = path.join(distPath, 'index.html');
  
  if (fs.existsSync(indexPath)) {
    res.sendFile(indexPath);
  } else {
    // Status page with app integration
    res.send(`
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>YesPlayMusic - Home Assistant</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }
        .container { 
            text-align: center; 
            max-width: 600px; 
            padding: 40px 20px;
        }
        .logo { 
            font-size: 4rem; 
            margin-bottom: 20px; 
            animation: bounce 2s infinite;
        }
        @keyframes bounce {
            0%, 20%, 50%, 80%, 100% { transform: translateY(0); }
            40% { transform: translateY(-10px); }
            60% { transform: translateY(-5px); }
        }
        .card { 
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 40px;
            margin: 20px 0;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        .status { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            margin: 15px 0;
            padding: 10px 15px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
        }
        .status.ok { border-left: 4px solid #4caf50; }
        .status.building { border-left: 4px solid #ff9800; }
        .btn { 
            background: rgba(255, 255, 255, 0.2);
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 25px;
            cursor: pointer;
            margin: 10px;
            font-size: 16px;
            transition: all 0.3s ease;
        }
        .btn:hover { 
            background: rgba(255, 255, 255, 0.3);
            transform: translateY(-2px);
        }
        .spinner { 
            width: 30px; 
            height: 30px; 
            border: 3px solid rgba(255,255,255,0.3); 
            border-top: 3px solid white; 
            border-radius: 50%; 
            animation: spin 1s linear infinite;
            display: inline-block;
        }
        @keyframes spin { 
            0% { transform: rotate(0deg); } 
            100% { transform: rotate(360deg); } 
        }
        .info { 
            text-align: left; 
            font-size: 14px; 
            opacity: 0.9;
            line-height: 1.6;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">🎵</div>
        <h1>YesPlayMusic</h1>
        <p>Home Assistant 加载项</p>
        
        <div class="card">
            <h2>🚀 服务状态</h2>
            <div class="status ok">
                <span>容器运行</span>
                <span>✅ 正常</span>
            </div>
            <div class="status ok">
                <span>API 代理</span>
                <span>✅ 已配置</span>
            </div>
            <div class="status building">
                <span>前端应用</span>
                <span><div class="spinner"></div> 构建中</span>
            </div>
        </div>
        
        <div class="card">
            <h3>📊 配置信息</h3>
            <div class="info">
                <strong>网易云API:</strong> ${apiUrl}<br>
                <strong>服务端口:</strong> ${port}<br>
                <strong>服务地址:</strong> ${host}<br>
                <strong>状态:</strong> 容器已启动，应用构建中
            </div>
        </div>
        
        <div class="card">
            <h3>🔧 操作</h3>
            <button class="btn" onclick="location.reload()">🔄 刷新页面</button>
            <button class="btn" onclick="testApi()">🧪 测试API</button>
            <button class="btn" onclick="window.open('/health', '_blank')">❤️ 健康检查</button>
        </div>
        
        <div id="message" style="margin-top: 20px;"></div>
    </div>
    
    <script>
        let refreshCount = 0;
        
        function showMessage(msg, type = 'info') {
            const div = document.getElementById('message');
            div.innerHTML = \`<div style="background: rgba(255,255,255,0.1); padding: 15px; border-radius: 10px; margin: 10px 0;">\${msg}</div>\`;
        }
        
        async function testApi() {
            try {
                showMessage('🧪 测试API连接...', 'info');
                const response = await fetch('/api/');
                if (response.ok || response.status === 404) {
                    showMessage('✅ API代理工作正常！', 'success');
                } else {
                    showMessage('⚠️ API返回状态: ' + response.status, 'warning');
                }
            } catch (err) {
                showMessage('❌ API连接失败: ' + err.message, 'error');
            }
        }
        
        // Auto refresh every 30 seconds, max 20 times
        setInterval(() => {
            refreshCount++;
            if (refreshCount < 20) {
                location.reload();
            } else {
                showMessage('⏰ 自动刷新已停止。如需继续等待，请手动刷新页面。', 'info');
            }
        }, 30000);
        
        // Test API on load
        setTimeout(testApi, 2000);
    </script>
</body>
</html>
    `);
  }
});

// Start server
const server = app.listen(port, host, () => {
  console.log(`🎵 YesPlayMusic server is running on http://${host}:${port}`);
  console.log(`🔗 API proxy target: ${apiUrl}`);
  console.log(`📁 Static files: ${fs.existsSync(distPath) ? 'Available' : 'Will be built in background'}`);
  console.log('=====================================');
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('Received SIGTERM, shutting down gracefully...');
  server.close(() => process.exit(0));
});

process.on('SIGINT', () => {
  console.log('Received SIGINT, shutting down gracefully...');  
  server.close(() => process.exit(0));
});
EOF

# Create background build script
RUN cat > build-yesplaymusic.sh << 'EOF'
#!/bin/bash
echo "🔄 Starting YesPlayMusic build in background..."

cd /app

# Try to clone the repository
if git clone --depth 1 https://github.com/stark81/my_yesplaymusic.git temp 2>/dev/null; then
    echo "✅ Repository cloned successfully"
    
    # Copy files
    cp -r temp/* . 2>/dev/null && echo "✅ Files copied"
    rm -rf temp
    
    # Configure npm with Chinese mirrors
    npm config set registry https://registry.npmmirror.com 2>/dev/null
    
    # Try to install dependencies (ignore errors)
    echo "📦 Installing dependencies..."
    npm install --force --legacy-peer-deps 2>/dev/null || echo "⚠️ Dependencies installation had issues"
    
    # Try to build
    echo "🏗️ Building application..."
    if npm run build 2>/dev/null; then
        echo "✅ Build completed successfully!"
        echo "🎉 YesPlayMusic is ready! Please refresh your browser."
    else
        echo "❌ Build failed, but server is still running"
    fi
else
    echo "❌ Failed to clone repository"
fi
EOF

RUN chmod +x build-yesplaymusic.sh

# Create main startup script
RUN cat > start.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting YesPlayMusic Home Assistant Addon..."

# Start build in background
./build-yesplaymusic.sh > build.log 2>&1 &
echo "📝 Build process started in background (check build.log)"

# Start server in foreground
node server.js
EOF

RUN chmod +x start.sh

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

CMD ["./start.sh"]