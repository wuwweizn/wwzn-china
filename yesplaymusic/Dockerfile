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
RUN git clone --depth 1 https://github.com/stark81/my_yesplaymusic.git /tmp/yesplaymusic \
    && cp -r /tmp/yesplaymusic/* /app/ \
    && rm -rf /tmp/yesplaymusic

# Install pnpm and dependencies
RUN npm install -g pnpm \
    && pnpm config set registry https://registry.npmmirror.com \
    && pnpm install --frozen-lockfile

# Build the application
RUN pnpm run build

# Clean up dev dependencies and install production server dependencies
RUN rm -rf node_modules \
    && npm install --only=production express http-proxy-middleware

# Create server.js file
RUN cat > server.js << 'EOF'
const express = require('express');
const path = require('path');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();
const port = process.env.PORT || 8080;
const host = process.env.HOST || '0.0.0.0';
const apiUrl = process.env.VUE_APP_NETEASE_API_URL || 'http://47.121.211.116:3001';

console.log('Starting YesPlayMusic server...');
console.log('Port:', port);
console.log('Host:', host);
console.log('API URL:', apiUrl);

// Proxy API requests to NetEase Cloud Music API
app.use('/api', createProxyMiddleware({
  target: apiUrl,
  changeOrigin: true,
  pathRewrite: {
    '^/api': ''
  },
  logLevel: 'info'
}));

// Serve static files from dist directory
app.use(express.static(path.join(__dirname, 'dist')));

// Handle client-side routing
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
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