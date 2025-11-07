const http = require('http');
const https = require('https');
const url = require('url');

const PORT = 3101;
const API_BASE = 'https://music-api.gdstudio.xyz';

// CORS 头
const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Access-Control-Max-Age': '86400',
};

// 代理请求到 GD 音乐台 API
function proxyRequest(req, res) {
  // 处理 OPTIONS 请求
  if (req.method === 'OPTIONS') {
    res.writeHead(204, CORS_HEADERS);
    res.end();
    return;
  }

  const parsedUrl = url.parse(req.url, true);
  const path = parsedUrl.path;
  
  // 构建目标 URL
  const targetUrl = `${API_BASE}${path}`;
  
  console.log(`[Proxy] ${req.method} ${path} -> ${targetUrl}`);

  const options = {
    method: req.method,
    headers: {
      ...req.headers,
      host: new URL(API_BASE).host,
    },
  };

  const proxyReq = https.request(targetUrl, options, (proxyRes) => {
    const headers = {
      ...CORS_HEADERS,
      'content-type': proxyRes.headers['content-type'] || 'application/json',
    };

    res.writeHead(proxyRes.statusCode, headers);

    proxyRes.on('data', (chunk) => {
      res.write(chunk);
    });

    proxyRes.on('end', () => {
      res.end();
    });
  });

  proxyReq.on('error', (err) => {
    console.error(`[Proxy Error] ${err.message}`);
    res.writeHead(500, { ...CORS_HEADERS, 'content-type': 'application/json' });
    res.end(JSON.stringify({ error: 'Proxy request failed', message: err.message }));
  });

  if (req.method === 'POST' || req.method === 'PUT') {
    req.on('data', (chunk) => {
      proxyReq.write(chunk);
    });
  }

  req.on('end', () => {
    proxyReq.end();
  });
}

// 创建服务器
const server = http.createServer(proxyRequest);

server.listen(PORT, '0.0.0.0', () => {
  console.log(`[API Proxy] Running on http://0.0.0.0:${PORT}`);
  console.log(`[API Proxy] Proxying requests to ${API_BASE}`);
});

// 错误处理
server.on('error', (err) => {
  console.error(`[Server Error] ${err.message}`);
});

process.on('SIGTERM', () => {
  console.log('[API Proxy] Shutting down...');
  server.close(() => {
    console.log('[API Proxy] Stopped');
    process.exit(0);
  });
});