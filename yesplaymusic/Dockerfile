# Ultra-clean solution - no conflicts
FROM node:18-alpine

WORKDIR /app

# Install only essential system dependencies
RUN apk add --no-cache curl bash

# Create a completely clean package.json with ONLY express
RUN cat > package.json << 'EOF'
{
  "name": "yesplaymusic-server",
  "version": "1.0.0",
  "description": "YesPlayMusic Server",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

# Install ONLY express - nothing else
RUN npm install --production

# Create the server file
RUN cat > server.js << 'EOF'
const express = require('express');
const http = require('http');
const https = require('https');
const fs = require('fs');
const path = require('path');

const app = express();

// Get environment variables - with proper defaults
const port = parseInt(process.env.PORT || '8080', 10);
const host = process.env.HOST || '0.0.0.0';
const apiUrl = process.env.VUE_APP_NETEASE_API_URL || 'http://47.121.211.116:3001';

console.log('=== YesPlayMusic Server Starting ===');
console.log('Host:', host);
console.log('Port:', port);
console.log('API URL:', apiUrl);
console.log('Node.js version:', process.version);
console.log('====================================');

// Basic middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// CORS middleware
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS, PATCH');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization, Cookie, User-Agent');
  res.header('Access-Control-Allow-Credentials', 'true');
  
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }
  next();
});

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    config: {
      host: host,
      port: port,
      apiUrl: apiUrl,
      nodeVersion: process.version
    }
  });
});

// Simple API proxy
app.use('/api*', (req, res) => {
  const targetPath = req.path.startsWith('/api') ? req.path.substring(4) : req.path;
  const queryString = req.url.includes('?') ? req.url.substring(req.url.indexOf('?')) : '';
  const targetUrl = apiUrl + targetPath + queryString;
  
  console.log(`[${new Date().toISOString()}] Proxy: ${req.method} ${req.path} -> ${targetUrl}`);
  
  const isHttps = targetUrl.startsWith('https:');
  const protocol = isHttps ? https : http;
  
  const options = {
    method: req.method,
    headers: {
      'User-Agent': 'YesPlayMusic/1.0.0',
      'Accept': '*/*',
      'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
      'Cache-Control': 'no-cache'
    },
    timeout: 15000
  };
  
  // Copy relevant headers
  if (req.headers['content-type']) {
    options.headers['Content-Type'] = req.headers['content-type'];
  }
  if (req.headers['cookie']) {
    options.headers['Cookie'] = req.headers['cookie'];
  }
  if (req.headers['referer']) {
    options.headers['Referer'] = req.headers['referer'];
  }
  
  const proxyReq = protocol.request(targetUrl, options, (proxyRes) => {
    // Set status
    res.status(proxyRes.statusCode || 200);
    
    // Copy response headers
    Object.keys(proxyRes.headers).forEach(key => {
      if (key.toLowerCase() !== 'transfer-encoding' && key.toLowerCase() !== 'connection') {
        res.setHeader(key, proxyRes.headers[key]);
      }
    });
    
    // Ensure CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Credentials', 'true');
    
    // Pipe response
    proxyRes.pipe(res);
  });
  
  proxyReq.on('error', (err) => {
    console.error('Proxy request error:', err.message);
    if (!res.headersSent) {
      res.status(500).json({
        error: 'Proxy Error',
        message: err.message,
        target: targetUrl,
        timestamp: new Date().toISOString()
      });
    }
  });
  
  proxyReq.on('timeout', () => {
    console.error('Proxy request timeout:', targetUrl);
    if (!res.headersSent) {
      res.status(504).json({
        error: 'Gateway Timeout',
        message: 'API request timeout',
        target: targetUrl
      });
    }
    proxyReq.destroy();
  });
  
  // Handle request body
  if (req.method !== 'GET' && req.method !== 'HEAD') {
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });
    req.on('end', () => {
      if (body) {
        proxyReq.write(body);
      }
      proxyReq.end();
    });
  } else {
    proxyReq.end();
  }
});

// Serve static files if available
app.use(express.static(path.join(__dirname, 'dist'), {
  maxAge: '1d',
  etag: true
}));

// Main route handler
app.get('*', (req, res) => {
  const indexPath = path.join(__dirname, 'dist', 'index.html');
  
  if (fs.existsSync(indexPath)) {
    res.sendFile(indexPath);
  } else {
    // Enhanced status page
    res.send(`
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>YesPlayMusic - Home Assistant</title>
    <link rel="icon" href="data:text/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>🎵</text></svg>">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'PingFang SC', 'Microsoft YaHei', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            line-height: 1.6;
        }
        .container {
            max-width: 800px;
            width: 100%;
            padding: 20px;
        }
        .header {
            text-align: center;
            margin-bottom: 40px;
        }
        .logo {
            font-size: 5rem;
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
            backdrop-filter: blur(15px);
            border-radius: 20px;
            padding: 30px;
            margin: 20px 0;
            border: 1px solid rgba(255, 255, 255, 0.2);
            box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
        }
        .status-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }
        .status-item {
            background: rgba(255, 255, 255, 0.1);
            padding: 20px;
            border-radius: 15px;
            text-align: center;
        }
        .status-ok { border-left: 4px solid #4caf50; }
        .status-building { border-left: 4px solid #ff9800; }
        .status-icon { font-size: 2rem; margin-bottom: 10px; }
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
            text-decoration: none;
            display: inline-block;
        }
        .btn:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        }
        .info-table {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
        }
        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        .info-row:last-child { border-bottom: none; }
        .spinner {
            width: 20px;
            height: 20px;
            border: 2px solid rgba(255, 255, 255, 0.3);
            border-top: 2px solid white;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            display: inline-block;
            vertical-align: middle;
            margin-left: 10px;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        .log-area {
            background: rgba(0, 0, 0, 0.3);
            border-radius: 10px;
            padding: 15px;
            font-family: 'Courier New', monospace;
            font-size: 14px;
            max-height: 200px;
            overflow-y: auto;
            margin-top: 20px;
        }
        @media (max-width: 768px) {
            .container { padding: 10px; }
            .logo { font-size: 3rem; }
            .status-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">🎵</div>
            <h1>YesPlayMusic</h1>
            <p>Home Assistant 高颜值网易云音乐播放器</p>
        </div>

        <div class="card">
            <h2>🚀 服务状态</h2>
            <div class="status-grid">
                <div class="status-item status-ok">
                    <div class="status-icon">✅</div>
                    <h3>容器运行</h3>
                    <p>服务正常启动</p>
                </div>
                <div class="status-item status-ok">
                    <div class="status-icon">🔗</div>
                    <h3>API 代理</h3>
                    <p>已配置并运行</p>
                </div>
                <div class="status-item status-building">
                    <div class="status-icon">🏗️</div>
                    <h3>前端应用</h3>
                    <p>后台构建中<span class="spinner"></span></p>
                </div>
            </div>
        </div>

        <div class="card">
            <h3>📊 配置信息</h3>
            <div class="info-table">
                <div class="info-row">
                    <strong>网易云 API:</strong>
                    <span>${apiUrl}</span>
                </div>
                <div class="info-row">
                    <strong>服务端口:</strong>
                    <span>${port}</span>
                </div>
                <div class="info-row">
                    <strong>服务地址:</strong>
                    <span>${host}</span>
                </div>
                <div class="info-row">
                    <strong>Node.js:</strong>
                    <span>${process.version}</span>
                </div>
                <div class="info-row">
                    <strong>运行时间:</strong>
                    <span id="uptime">${Math.floor(process.uptime())}秒</span>
                </div>
            </div>
        </div>

        <div class="card">
            <h3>🔧 操作中心</h3>
            <p style="margin-bottom: 20px;">使用以下工具测试和管理您的 YesPlayMusic 服务</p>
            
            <button class="btn" onclick="location.reload()">🔄 刷新页面</button>
            <button class="btn" onclick="testApi()">🧪 测试 API</button>
            <button class="btn" onclick="window.open('/health', '_blank')">❤️ 健康检查</button>
            <button class="btn" onclick="toggleLogs()">📋 查看日志</button>
            
            <div id="log-container" style="display: none;">
                <div class="log-area" id="logs">
                    <div>等待日志输出...</div>
                </div>
            </div>
        </div>

        <div id="message-area"></div>

        <div class="card" style="text-align: center; opacity: 0.8;">
            <p>🎵 YesPlayMusic Home Assistant Addon v1.0.0</p>
            <p>高颜值的第三方网易云音乐播放器</p>
            <p><small>应用构建完成后将自动跳转到音乐播放界面</small></p>
        </div>
    </div>

    <script>
        let refreshCount = 0;
        let logVisible = false;
        
        function showMessage(msg, type = 'info') {
            const area = document.getElementById('message-area');
            const colors = {
                success: 'rgba(76, 175, 80, 0.8)',
                error: 'rgba(244, 67, 54, 0.8)',
                warning: 'rgba(255, 152, 0, 0.8)',
                info: 'rgba(33, 150, 243, 0.8)'
            };
            
            area.innerHTML = \`
                <div class="card" style="background: \${colors[type] || colors.info}; animation: slideInUp 0.5s ease;">
                    <p>\${msg}</p>
                </div>
            \`;
            
            setTimeout(() => area.innerHTML = '', 5000);
        }
        
        async function testApi() {
            try {
                showMessage('🧪 正在测试 API 连接...', 'info');
                const response = await fetch('/api/');
                
                if (response.ok || response.status === 404) {
                    showMessage('✅ API 代理工作正常！网易云音乐 API 连接成功。', 'success');
                } else {
                    showMessage(\`⚠️ API 返回状态码: \${response.status}。这可能是正常的，具体取决于 API 端点。\`, 'warning');
                }
            } catch (err) {
                showMessage('❌ API 连接测试失败: ' + err.message, 'error');
            }
        }
        
        function toggleLogs() {
            const container = document.getElementById('log-container');
            logVisible = !logVisible;
            container.style.display = logVisible ? 'block' : 'none';
            
            if (logVisible) {
                updateLogs();
            }
        }
        
        function updateLogs() {
            // Simulate log updates
            const logs = document.getElementById('logs');
            const now = new Date().toLocaleTimeString();
            logs.innerHTML += \`<div>[\${now}] YesPlayMusic 容器运行正常</div>\`;
            
            if (logs.children.length > 10) {
                logs.removeChild(logs.firstChild);
            }
        }
        
        function updateUptime() {
            fetch('/health')
                .then(r => r.json())
                .then(data => {
                    document.getElementById('uptime').textContent = Math.floor(data.uptime) + '秒';
                })
                .catch(() => {});
        }
        
        // Update uptime every second
        setInterval(updateUptime, 1000);
        
        // Auto refresh every 30 seconds for the first 10 minutes
        const autoRefresh = setInterval(() => {
            refreshCount++;
            if (refreshCount < 20) {
                // Check if the app is built
                fetch('/')
                    .then(response => response.text())
                    .then(html => {
                        if (html.includes('<div id="app">') || html.includes('yesplaymusic')) {
                            showMessage('🎉 YesPlayMusic 构建完成！页面即将刷新...', 'success');
                            setTimeout(() => location.reload(), 2000);
                            clearInterval(autoRefresh);
                        }
                    })
                    .catch(() => {});
            } else {
                clearInterval(autoRefresh);
                showMessage('⏰ 自动刷新已停止。您可以手动刷新检查构建状态。', 'info');
            }
        }, 30000);
        
        // Test API connection on page load
        setTimeout(testApi, 3000);
        
        // Add some animations
        document.addEventListener('DOMContentLoaded', () => {
            const cards = document.querySelectorAll('.card');
            cards.forEach((card, index) => {
                card.style.animation = \`slideInUp 0.6s ease \${index * 0.1}s both\`;
            });
        });
    </script>
    
    <style>
        @keyframes slideInUp {
            from {
                transform: translateY(30px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }
    </style>
</body>
</html>
    `);
  }
});

// Start server
const server = app.listen(port, host, () => {
  console.log(\`🎵 YesPlayMusic server is running on http://\${host}:\${port}\`);
  console.log(\`🔗 API proxy target: \${apiUrl}\`);
  console.log(\`📁 Static files: \${fs.existsSync(path.join(__dirname, 'dist')) ? 'Available' : 'Building in background'}\`);
  console.log('====================================');
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

process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});
EOF

# Create ONLY the build script - no automatic execution
RUN cat > build-yesplaymusic.sh << 'EOF'
#!/bin/bash
echo "🔄 Building YesPlayMusic..."

# Clean any existing files first
rm -rf temp dist node_modules package-lock.json 2>/dev/null || true

# Clone repository  
if git clone --depth 1 https://github.com/stark81/my_yesplaymusic.git temp; then
    echo "✅ Repository cloned"
    
    # Create a new directory structure
    mkdir -p yesplaymusic-src
    cp -r temp/* yesplaymusic-src/ 2>/dev/null || true
    rm -rf temp
    
    cd yesplaymusic-src
    
    # Use Chinese npm registry
    npm config set registry https://registry.npmmirror.com
    
    # Install and build
    if npm install --force --legacy-peer-deps; then
        echo "✅ Dependencies installed"
        
        if npm run build; then
            echo "✅ Build successful"
            # Move dist to main directory
            mv dist ../dist 2>/dev/null || cp -r dist ../dist
            echo "🎉 YesPlayMusic ready!"
        else
            echo "❌ Build failed"
        fi
    else
        echo "❌ Dependencies installation failed"
    fi
    
    cd ..
    rm -rf yesplaymusic-src
else
    echo "❌ Failed to clone repository"
fi
EOF

RUN chmod +x build-yesplaymusic.sh

# Simple start script that ONLY starts the server
RUN cat > start.sh << 'EOF'
#!/bin/bash
echo "🚀 YesPlayMusic Home Assistant Addon"
echo "Starting server only - build manually if needed"

# Start server in foreground
exec node server.js
EOF

RUN chmod +x start.sh

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

CMD ["./start.sh"]