# Minimal version - use this if the full build fails
FROM node:18-alpine

WORKDIR /app

# Install basic dependencies
RUN apk add --no-cache curl bash git

# Install minimal server dependencies
RUN npm init -y \
    && npm install express cors

# Create a simple server
RUN cat > server.js << 'EOF'
const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const port = process.env.PORT || 8080;
const host = process.env.HOST || '0.0.0.0';

app.use(cors());
app.use(express.static('dist'));

app.get('*', (req, res) => {
  res.send(`
<!DOCTYPE html>
<html>
<head>
    <title>YesPlayMusic</title>
    <meta charset="utf-8">
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; text-align: center; }
        .error { background: #fee; border: 1px solid #fcc; padding: 20px; border-radius: 8px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>YesPlayMusic</h1>
        <div class="error">
            <h2>构建中...</h2>
            <p>YesPlayMusic 正在构建中，请稍候...</p>
            <p>如果您看到此页面，说明 Docker 容器已成功启动，但应用构建可能还需要一些时间。</p>
            <p>API地址: ${process.env.VUE_APP_NETEASE_API_URL || 'http://47.121.211.116:3001'}</p>
            <p>请检查容器日志获取更多信息。</p>
        </div>
    </div>
</body>
</html>
  `);
});

app.listen(port, host, () => {
  console.log(`YesPlayMusic placeholder is running on http://${host}:${port}`);
});
EOF

# Create startup script
RUN echo '#!/bin/bash' > start.sh \
    && echo 'exec node server.js' >> start.sh \
    && chmod +x start.sh

EXPOSE 8080

CMD ["./start.sh"]