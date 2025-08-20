# Minimal working version - use this to test first
FROM node:18-alpine

WORKDIR /app

# Install basic system dependencies
RUN apk add --no-cache curl bash git

# Create a minimal server that works
RUN npm init -y && npm install express

# Create server.js
RUN cat > server.js << 'EOF'
const express = require('express');
const path = require('path');
const fs = require('fs');

const app = express();
const port = process.env.PORT || 8080;
const host = process.env.HOST || '0.0.0.0';
const apiUrl = process.env.VUE_APP_NETEASE_API_URL || 'http://47.121.211.116:3001';

console.log('YesPlayMusic Container Started');
console.log('Host:', host, 'Port:', port, 'API:', apiUrl);

// CORS headers
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
  if (req.method === 'OPTIONS') {
    res.sendStatus(200);
  } else {
    next();
  }
});

// Simple API proxy
app.use('/api', (req, res) => {
  const targetUrl = apiUrl + req.url;
  console.log('Proxy:', req.method, req.url, '->', targetUrl);
  
  const protocol = targetUrl.startsWith('https:') ? require('https') : require('http');
  const options = {
    method: req.method,
    headers: { ...req.headers, 'host': new URL(apiUrl).host }
  };
  
  const proxyReq = protocol.request(targetUrl, options, (proxyRes) => {
    res.statusCode = proxyRes.statusCode;
    Object.keys(proxyRes.headers).forEach(key => {
      res.setHeader(key, proxyRes.headers[key]);
    });
    proxyRes.pipe(res);
  });
  
  proxyReq.on('error', (err) => {
    console.error('Proxy error:', err.message);
    res.status(500).json({ error: 'Proxy error' });
  });
  
  req.pipe(proxyReq);
});

// Try to serve built files, fallback to status page
app.use(express.static('dist'));

app.get('*', (req, res) => {
  const indexPath = path.join(__dirname, 'dist', 'index.html');
  if (fs.existsSync(indexPath)) {
    res.sendFile(indexPath);
  } else {
    res.send(`
<!DOCTYPE html>
<html>
<head>
    <title>YesPlayMusic - 正在构建</title>
    <meta charset="utf-8">
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #f0f2f5; }
        .container { max-width: 600px; margin: 50px auto; text-align: center; }
        .card { background: white; padding: 40px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .spinner { width: 40px; height: 40px; border: 4px solid #f3f3f3; border-top: 4px solid #1890ff; border-radius: 50%; animation: spin 1s linear infinite; margin: 20px auto; }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
        .info { background: #e6f7ff; border: 1px solid #91d5ff; padding: 15px; border-radius: 5px; margin: 20px 0; text-align: left; }
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
            <h1>🎵 YesPlayMusic</h1>
            <div class="spinner"></div>
            <h2>容器运行中</h2>
            <p>YesPlayMusic Docker 容器已成功启动！</p>
            
            <div class="info">
                <strong>当前状态:</strong><br>
                • 容器状态: ✅ 运行中<br>
                • API代理: ✅ 已配置 (${apiUrl})<br>
                • 端口: ${port}<br>
                • 前端构建: 🔄 构建中或未完成
            </div>
            
            <p>如果长时间看到此页面，可能需要重新构建应用。</p>
            <button onclick="location.reload()" style="background:#1890ff; color:white; border:none; padding:10px 20px; border-radius:5px; cursor:pointer;">刷新页面</button>
        </div>
    </div>
    <script>setTimeout(() => location.reload(), 30000);</script>
</body>
</html>
    `);
  }
});

app.listen(port, host, () => {
  console.log(`Server running on http://${host}:${port}`);
  console.log(`API proxy: ${apiUrl}`);
});
EOF

# Try to clone and build YesPlayMusic (in background, allow failure)
RUN echo '#!/bin/bash' > build-app.sh && \
    echo 'cd /app' >> build-app.sh && \
    echo 'git clone --depth 1 https://github.com/stark81/my_yesplaymusic.git temp || exit 1' >> build-app.sh && \
    echo 'cp -r temp/* . 2>/dev/null || true' >> build-app.sh && \
    echo 'rm -rf temp' >> build-app.sh && \
    echo 'npm config set registry https://registry.npmmirror.com' >> build-app.sh && \
    echo 'npm install --force 2>/dev/null || echo "Install failed"' >> build-app.sh && \
    echo 'npm run build 2>/dev/null || echo "Build failed"' >> build-app.sh && \
    echo 'echo "Build process completed (may have failed)"' >> build-app.sh && \
    chmod +x build-app.sh

# Create startup script that builds in background
RUN cat > start.sh << 'EOF'
#!/bin/bash
echo "Starting YesPlayMusic container..."

# Start build in background
./build-app.sh &
BUILD_PID=$!

# Start server immediately
node server.js
EOF

RUN chmod +x start.sh

EXPOSE 8080
CMD ["./start.sh"]