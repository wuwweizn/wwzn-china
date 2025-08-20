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