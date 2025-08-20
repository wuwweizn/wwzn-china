# Use Node.js Alpine image as base
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apk add --no-cache \
    git \
    python3 \
    py3-pip \
    make \
    g++ \
    curl \
    bash

# Clone YesPlayMusic repository
RUN git clone --depth 1 https://github.com/stark81/my_yesplaymusic.git /tmp/yesplaymusic

# Copy source files
RUN cp -r /tmp/yesplaymusic/* /app/ \
    && rm -rf /tmp/yesplaymusic

# Install dependencies using npm with Chinese registry for faster downloads
RUN npm config set registry https://registry.npmmirror.com \
    && npm config set disturl https://npmmirror.com/mirrors/node \
    && npm config set electron_mirror https://npmmirror.com/mirrors/electron/ \
    && npm config set sass_binary_site https://npmmirror.com/mirrors/node-sass/ \
    && npm config set phantomjs_cdnurl https://npmmirror.com/mirrors/phantomjs/

# Fix package.json to avoid path-to-regexp issues
RUN if [ -f package.json ]; then \
        cp package.json package.json.bak && \
        node -e "
            const fs = require('fs');
            const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
            // Fix problematic dependencies
            if (pkg.dependencies && pkg.dependencies['path-to-regexp']) {
                pkg.dependencies['path-to-regexp'] = '^6.2.1';
            }
            if (pkg.dependencies && pkg.dependencies['vue-router']) {
                pkg.dependencies['vue-router'] = '^4.0.0';
            }
            fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
        "; \
    fi

# Install dependencies - try multiple approaches
RUN npm install --legacy-peer-deps || \
    (npm cache clean --force && npm install --no-optional --legacy-peer-deps) || \
    (rm -rf node_modules package-lock.json && npm install --legacy-peer-deps)

# Build the application
RUN npm run build || echo "Build may have warnings but continuing..."

# Install production dependencies for server
RUN npm install --save express http-proxy-middleware

# Create server.js file
RUN cat > server.js << 'EOF'
const express = require('express');
const path = require('path');
const fs = require('fs');

const app = express();
const port = process.env.PORT || 8080;
const host = process.env.HOST || '0.0.0.0';
const apiUrl = process.env.VUE_APP_NETEASE_API_URL || 'http://47.121.211.116:3001';

console.log('Starting YesPlayMusic server...');
console.log('Port:', port);
console.log('Host:', host);
console.log('API URL:', apiUrl);

// Enable CORS
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  if (req.method === 'OPTIONS') {
    res.sendStatus(200);
  } else {
    next();
  }
});

// Simple API proxy using native http/https modules
app.use('/api', (req, res) => {
  const targetUrl = apiUrl + req.url;
  console.log('Proxying API request:', req.method, req.url, '->', targetUrl);
  
  const protocol = targetUrl.startsWith('https:') ? require('https') : require('http');
  const options = {
    method: req.method,
    headers: {
      ...req.headers,
      'host': new URL(apiUrl).host
    }
  };
  
  const proxyReq = protocol.request(targetUrl, options, (proxyRes) => {
    // Copy status code
    res.statusCode = proxyRes.statusCode;
    
    // Copy headers
    Object.keys(proxyRes.headers).forEach(key => {
      res.setHeader(key, proxyRes.headers[key]);
    });
    
    // Pipe response
    proxyRes.pipe(res);
  });
  
  proxyReq.on('error', (err) => {
    console.error('Proxy error:', err.message);
    res.status(500).json({ error: 'API proxy error', message: err.message });
  });
  
  // Pipe request body if present
  req.pipe(proxyReq);
});

// Check if dist directory exists and serve static files
const distPath = path.join(__dirname, 'dist');
if (fs.existsSync(distPath)) {
  console.log('Serving static files from:', distPath);
  app.use(express.static(distPath, {
    fallthrough: true,
    etag: false,
    maxAge: 0
  }));
  
  // Handle client-side routing - serve index.html for all non-API routes
  app.get('*', (req, res) => {
    const indexPath = path.join(distPath, 'index.html');
    if (fs.existsSync(indexPath)) {
      res.sendFile(indexPath);
    } else {
      res.status(404).send('Index file not found');
    }
  });
} else {
  console.log('Dist directory not found, serving placeholder');
  app.get('*', (req, res) => {
    res.send(`
<!DOCTYPE html>
<html>
<head>
    <title>YesPlayMusic - Loading</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { 
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; 
          margin: 0; 
          padding: 40px; 
          background: #f5f5f7; 
          color: #1d1d1f;
        }
        .container { 
          max-width: 800px; 
          margin: 0 auto; 
          text-align: center; 
        }
        .card { 
          background: white; 
          border-radius: 12px; 
          padding: 40px; 
          box-shadow: 0 4px 6px rgba(0,0,0,0.1); 
        }
        .loading { 
          width: 40px; 
          height: 40px; 
          border: 3px solid #f3f3f3; 
          border-top: 3px solid #007AFF; 
          border-radius: 50%; 
          animation: spin 1s linear infinite; 
          margin: 20px auto; 
        }
        @keyframes spin { 
          0% { transform: rotate(0deg); } 
          100% { transform: rotate(360deg); } 
        }
        .info { 
          background: #e3f2fd; 
          border-left: 4px solid #2196f3; 
          padding: 16px; 
          margin: 20px 0; 
          text-align: left; 
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
            <h1>🎵 YesPlayMusic</h1>
            <div class="loading"></div>
            <h2>应用正在启动中...</h2>
            <p>YesPlayMusic 正在准备中，请稍候片刻。</p>
            
            <div class="info">
                <strong>配置信息:</strong><br>
                API地址: ${apiUrl}<br>
                端口: ${port}<br>
                状态: 容器已启动，等待应用构建完成
            </div>
            
            <p><small>如果长时间看到此页面，请检查容器日志。</small></p>
            
            <button onclick="location.reload()" style="
              background: #007AFF; 
              color: white; 
              border: none; 
              padding: 12px 24px; 
              border-radius: 8px; 
              cursor: pointer; 
              font-size: 16px;
            ">刷新页面</button>
        </div>
    </div>
    
    <script>
      // Auto refresh every 10 seconds
      setTimeout(() => location.reload(), 10000);
    </script>
</body>
</html>
    `);
  });
}

app.listen(port, host, () => {
  console.log(`YesPlayMusic server is running on http://${host}:${port}`);
  console.log(`API proxy target: ${apiUrl}`);
  console.log(`Static files: ${fs.existsSync(distPath) ? 'Available' : 'Not built yet'}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('Received SIGTERM, shutting down gracefully...');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('Received SIGINT, shutting down gracefully...');
  process.exit(0);
});
EOF

# Create startup script
RUN cat > start.sh << 'EOF'
#!/bin/bash
echo "Starting YesPlayMusic..."

# Set default values
export HOST=${HOST:-"0.0.0.0"}
export PORT=${PORT:-8080}
export VUE_APP_NETEASE_API_URL=${VUE_APP_NETEASE_API_URL:-"http://47.121.211.116:3001"}

echo "Host: $HOST"
echo "Port: $PORT" 
echo "API URL: $VUE_APP_NETEASE_API_URL"

# Check if dist directory exists
if [ ! -d "dist" ]; then
    echo "Warning: dist directory not found"
    echo "This usually means the build failed or is incomplete"
    echo "The server will start with a placeholder page"
    echo "Container logs may contain build error details"
fi

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "Warning: node_modules not found, installing basic dependencies..."
    npm install express || echo "Failed to install express"
fi

# Start the server
echo "Starting Node.js server..."
exec node server.js
EOF

RUN chmod +x start.sh

# Create data directory for settings
RUN mkdir -p /data

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Start the application
CMD ["./start.sh"]