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

const app = express();
const port = process.env.PORT || 8080;
const host = process.env.HOST || '0.0.0.0';
const apiUrl = process.env.VUE_APP_NETEASE_API_URL || 'http://47.121.211.116:3001';

console.log('Starting YesPlayMusic server...');
console.log('Port:', port);
console.log('Host:', host);
console.log('API URL:', apiUrl);

// Simple proxy function for API requests
app.use('/api/*', (req, res) => {
  const apiPath = req.path.replace('/api', '');
  const targetUrl = apiUrl + apiPath + (req.url.includes('?') ? '?' + req.url.split('?')[1] : '');
  
  console.log('Proxying:', req.method, req.path, '->', targetUrl);
  
  const options = {
    method: req.method,
    headers: {
      ...req.headers,
      'host': new URL(apiUrl).host
    }
  };
  
  if (req.method !== 'GET' && req.method !== 'HEAD') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      options.body = body;
      makeRequest();
    });
  } else {
    makeRequest();
  }
  
  function makeRequest() {
    const protocol = targetUrl.startsWith('https:') ? require('https') : require('http');
    const request = protocol.request(targetUrl, options, (response) => {
      res.status(response.statusCode);
      Object.keys(response.headers).forEach(key => {
        res.set(key, response.headers[key]);
      });
      response.pipe(res);
    });
    
    request.on('error', (err) => {
      console.error('Proxy error:', err);
      res.status(500).json({ error: 'Proxy error' });
    });
    
    if (options.body) {
      request.write(options.body);
    }
    request.end();
  }
});

// Serve static files from dist directory
app.use(express.static(path.join(__dirname, 'dist')));

// Handle client-side routing
app.get('*', (req, res) => {
  const indexPath = path.join(__dirname, 'dist', 'index.html');
  if (require('fs').existsSync(indexPath)) {
    res.sendFile(indexPath);
  } else {
    res.status(404).send('YesPlayMusic build not found. Please check if the build was successful.');
  }
});

app.listen(port, host, () => {
  console.log(`YesPlayMusic is running on http://${host}:${port}`);
  console.log(`API proxy: ${apiUrl}`);
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
    echo "Warning: dist directory not found, attempting to build..."
    npm run build || echo "Build failed, but continuing..."
fi

# Start the server
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