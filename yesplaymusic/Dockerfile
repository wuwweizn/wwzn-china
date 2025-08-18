ARG BUILD_ARCH
FROM nginx:alpine

# 安装必要工具
RUN apk add --no-cache \
    supervisor \
    jq \
    gettext \
    curl \
    bash \
    wget \
    unzip

# 尝试下载YesPlayMusic预构建版本，如果失败则使用备用方案
RUN mkdir -p /tmp/download && cd /tmp/download && \
    echo "📥 尝试下载YesPlayMusic预构建版本..." && \
    (wget -q --timeout=30 -O yesplaymusic.zip \
        "https://github.com/qier222/YesPlayMusic/releases/latest/download/YesPlayMusic-web.zip" || \
     wget -q --timeout=30 -O yesplaymusic.zip \
        "https://codeload.github.com/qier222/YesPlayMusic/zip/refs/heads/main") && \
    echo "📦 解压文件..." && \
    unzip -q yesplaymusic.zip && \
    echo "📁 查找构建文件..." && \
    (find . -name "dist" -type d -exec cp -r {}/* /usr/share/nginx/html/ \; 2>/dev/null || \
     find . -name "build" -type d -exec cp -r {}/* /usr/share/nginx/html/ \; 2>/dev/null || \
     find . -name "public" -type d -exec cp -r {}/* /usr/share/nginx/html/ \; 2>/dev/null || \
     echo "⚠️ 未找到构建文件，将使用自定义页面") && \
    rm -rf /tmp/download

# 创建高质量的YesPlayMusic风格页面
RUN cat > /usr/share/nginx/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>YesPlayMusic</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🎵</text></svg>">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
        }
        
        .app-container {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 24px;
            padding: 60px 40px;
            text-align: center;
            max-width: 500px;
            width: 90%;
            box-shadow: 0 25px 80px rgba(0, 0, 0, 0.15);
            position: relative;
            overflow: hidden;
        }
        
        .app-container::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #667eea, #764ba2);
        }
        
        .logo {
            font-size: 5rem;
            margin-bottom: 24px;
            animation: pulse 2s ease-in-out infinite;
        }
        
        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }
        
        h1 {
            color: #2d3748;
            font-size: 2.5rem;
            font-weight: 300;
            margin-bottom: 12px;
            letter-spacing: -0.02em;
        }
        
        .subtitle {
            color: #667eea;
            font-size: 1.1rem;
            margin-bottom: 40px;
            font-weight: 400;
        }
        
        .status-section {
            margin: 40px 0;
            padding: 30px;
            background: #f7fafc;
            border-radius: 16px;
            border-left: 4px solid #667eea;
        }
        
        .loading-spinner {
            width: 40px;
            height: 40px;
            margin: 20px auto;
            border: 3px solid #e2e8f0;
            border-top: 3px solid #667eea;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        .status-text {
            color: #4a5568;
            font-size: 1rem;
            margin: 16px 0;
        }
        
        .api-status {
            font-weight: 600;
            padding: 8px 16px;
            border-radius: 20px;
            margin: 16px auto;
            max-width: fit-content;
            font-size: 0.9rem;
        }
        
        .api-status.checking { background: #e6fffa; color: #00a3a3; }
        .api-status.success { background: #c6f6d5; color: #25855a; }
        .api-status.error { background: #fed7d7; color: #c53030; }
        
        .action-buttons {
            display: flex;
            gap: 12px;
            justify-content: center;
            flex-wrap: wrap;
            margin-top: 32px;
        }
        
        .btn {
            padding: 14px 28px;
            border: none;
            border-radius: 25px;
            font-size: 0.95rem;
            font-weight: 500;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 40px rgba(102, 126, 234, 0.4);
        }
        
        .btn-secondary {
            background: white;
            color: #4a5568;
            border: 2px solid #e2e8f0;
        }
        
        .btn-secondary:hover {
            border-color: #667eea;
            color: #667eea;
            transform: translateY(-1px);
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
            margin-top: 32px;
            text-align: left;
        }
        
        .info-item {
            padding: 16px;
            background: rgba(102, 126, 234, 0.05);
            border-radius: 12px;
            font-size: 0.9rem;
        }
        
        .info-label {
            font-weight: 600;
            color: #2d3748;
            margin-bottom: 4px;
        }
        
        .info-value {
            color: #667eea;
            font-family: 'Monaco', 'Consolas', monospace;
        }
        
        @media (max-width: 640px) {
            .app-container { padding: 40px 24px; }
            .logo { font-size: 4rem; }
            h1 { font-size: 2rem; }
            .info-grid { grid-template-columns: 1fr; }
            .action-buttons { flex-direction: column; align-items: center; }
            .btn { width: 100%; max-width: 280px; justify-content: center; }
        }
    </style>
</head>
<body>
    <div class="app-container">
        <div class="logo">🎵</div>
        <h1>YesPlayMusic</h1>
        <p class="subtitle">高颜值的第三方网易云播放器</p>
        
        <div class="status-section">
            <div class="loading-spinner"></div>
            <div class="status-text">正在初始化音乐服务...</div>
            <div id="api-status" class="api-status checking">检查API连接状态</div>
        </div>
        
        <div class="action-buttons">
            <button onclick="location.reload()" class="btn btn-primary">
                🔄 刷新页面
            </button>
            <a href="/api/" target="_blank" class="btn btn-secondary">
                🔧 检查API
            </a>
            <button onclick="testConnection()" class="btn btn-secondary">
                📡 测试连接
            </button>
        </div>
        
        <div class="info-grid">
            <div class="info-item">
                <div class="info-label">服务状态</div>
                <div class="info-value" id="service-status">启动中...</div>
            </div>
            <div class="info-item">
                <div class="info-label">API地址</div>
                <div class="info-value" id="api-url">配置中...</div>
            </div>
        </div>
    </div>
    
    <script>
        let retryCount = 0;
        const maxRetries = 15;
        
        async function checkAPI() {
            const statusEl = document.getElementById('api-status');
            const serviceStatusEl = document.getElementById('service-status');
            const apiUrlEl = document.getElementById('api-url');
            
            try {
                // 检查配置
                const configResponse = await fetch('/config.json');
                if (configResponse.ok) {
                    const config = await configResponse.json();
                    apiUrlEl.textContent = config.apiUrl || 'Unknown';
                }
                
                // 检查API连接
                const response = await fetch('/api/', {
                    method: 'GET',
                    timeout: 5000
                });
                
                if (response.ok) {
                    statusEl.textContent = '✅ API连接正常';
                    statusEl.className = 'api-status success';
                    serviceStatusEl.textContent = '运行中';
                    return true;
                } else {
                    statusEl.textContent = `⚠️ API响应异常 (${response.status})`;
                    statusEl.className = 'api-status error';
                    serviceStatusEl.textContent = '连接异常';
                }
            } catch (error) {
                statusEl.textContent = '❌ API连接失败';
                statusEl.className = 'api-status error';
                serviceStatusEl.textContent = '连接失败';
                console.error('API检查失败:', error);
            }
            return false;
        }
        
        async function testConnection() {
            document.getElementById('api-status').textContent = '🔄 正在测试...';
            document.getElementById('api-status').className = 'api-status checking';
            
            await new Promise(resolve => setTimeout(resolve, 1000));
            await checkAPI();
        }
        
        async function initializeApp() {
            retryCount++;
            console.log(`初始化尝试 ${retryCount}/${maxRetries}`);
            
            const apiOK = await checkAPI();
            
            if (apiOK) {
                document.querySelector('.status-text').textContent = '✅ 服务已就绪！';
                document.querySelector('.loading-spinner').style.display = 'none';
                
                // 如果API正常但页面内容不完整，提示用户
                if (retryCount > 5) {
                    document.querySelector('.status-text').innerHTML = 
                        '✅ 服务已就绪！<br><small style="color: #666;">如需完整功能请访问官方Demo</small>';
                }
            } else if (retryCount < maxRetries) {
                setTimeout(initializeApp, 3000);
            } else {
                document.querySelector('.status-text').textContent = '❌ 初始化超时，请检查配置';
                document.querySelector('.loading-spinner').style.display = 'none';
            }
        }
        
        // 页面加载后开始初始化
        document.addEventListener('DOMContentLoaded', initializeApp);
    </script>
</body>
</html>
EOF

# 创建配置文件模板
RUN echo '{"apiUrl":"/api","status":"initializing"}' > /usr/share/nginx/html/config.json

# 复制其他配置文件
COPY nginx.conf /etc/nginx/nginx.conf
COPY run.sh /run.sh
COPY supervisord.conf /etc/supervisord.conf

# 设置权限
RUN chmod +x /run.sh

# 创建日志目录
RUN mkdir -p /var/log/nginx /var/log/supervisor

# 暴露端口
EXPOSE 80 443

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# 启动
CMD ["/run.sh"]