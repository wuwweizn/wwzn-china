ARG BUILD_ARCH
FROM nginx:alpine

# 安装必要工具
RUN apk add --no-cache supervisor jq gettext curl bash

# 创建YesPlayMusic应用页面
RUN mkdir -p /usr/share/nginx/html && \
    cat > /usr/share/nginx/html/index.html << 'HTMLEOF'
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
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh; display: flex; align-items: center; justify-content: center;
        }
        
        .container {
            background: rgba(255, 255, 255, 0.95); backdrop-filter: blur(20px);
            border-radius: 24px; padding: 40px; max-width: 900px; width: 95%;
            box-shadow: 0 25px 80px rgba(0, 0, 0, 0.15); position: relative;
        }
        
        .container::before {
            content: ''; position: absolute; top: 0; left: 0; right: 0; height: 4px;
            background: linear-gradient(90deg, #667eea, #764ba2);
        }
        
        .header { text-align: center; margin-bottom: 30px; }
        
        .logo {
            font-size: 4rem; margin-bottom: 16px;
            animation: pulse 2s ease-in-out infinite;
        }
        
        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }
        
        h1 { color: #2d3748; font-size: 2.2rem; font-weight: 300; margin-bottom: 8px; }
        .subtitle { color: #667eea; font-size: 1rem; margin-bottom: 30px; }
        
        .main-content {
            display: grid; grid-template-columns: 1fr 1fr; gap: 30px; margin-bottom: 30px;
        }
        
        .player-section, .api-section {
            background: #f8fafc; border-radius: 16px; padding: 24px;
        }
        
        .api-section { background: #f0fff4; border-left: 4px solid #48bb78; }
        
        .section-title {
            font-size: 1.1rem; font-weight: 600; color: #2d3748; margin-bottom: 16px;
            display: flex; align-items: center; gap: 8px;
        }
        
        .music-player {
            background: white; border-radius: 12px; padding: 20px; text-align: center;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
        }
        
        .album-art {
            width: 120px; height: 120px; margin: 0 auto 16px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 12px; display: flex; align-items: center; justify-content: center;
            font-size: 3rem; color: white;
        }
        
        .song-info { margin-bottom: 20px; }
        .song-title { font-weight: 600; color: #2d3748; margin-bottom: 4px; }
        .artist-name { color: #718096; font-size: 0.9rem; }
        
        .controls {
            display: flex; justify-content: center; align-items: center; gap: 16px; margin-bottom: 16px;
        }
        
        .control-btn {
            width: 48px; height: 48px; border: none; border-radius: 50%;
            background: #f7fafc; cursor: pointer; display: flex; align-items: center;
            justify-content: center; font-size: 1.2rem; transition: all 0.2s;
        }
        
        .control-btn:hover { background: #edf2f7; transform: scale(1.05); }
        
        .play-btn {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white; width: 56px; height: 56px;
        }
        
        .progress-bar {
            width: 100%; height: 6px; background: #e2e8f0; border-radius: 3px;
            overflow: hidden; margin-bottom: 12px;
        }
        
        .progress {
            height: 100%; background: linear-gradient(90deg, #667eea, #764ba2);
            width: 35%; border-radius: 3px; transition: width 0.3s;
        }
        
        .time-info {
            display: flex; justify-content: space-between; font-size: 0.8rem; color: #718096;
        }
        
        .api-status {
            display: flex; align-items: center; gap: 12px; padding: 16px;
            background: white; border-radius: 12px; margin-bottom: 16px;
        }
        
        .status-indicator {
            width: 12px; height: 12px; border-radius: 50%; background: #48bb78;
            animation: blink 2s infinite;
        }
        
        @keyframes blink {
            0%, 50% { opacity: 1; }
            51%, 100% { opacity: 0.3; }
        }
        
        .api-info { font-size: 0.9rem; color: #2d3748; line-height: 1.5; }
        
        .action-buttons {
            display: flex; gap: 12px; justify-content: center; flex-wrap: wrap; margin-top: 20px;
        }
        
        .btn {
            padding: 12px 24px; border: none; border-radius: 20px; font-size: 0.9rem;
            font-weight: 500; cursor: pointer; transition: all 0.3s; text-decoration: none;
            display: inline-flex; align-items: center; gap: 8px;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea, #764ba2); color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px); box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
        }
        
        .btn-secondary {
            background: white; color: #4a5568; border: 2px solid #e2e8f0;
        }
        
        .btn-secondary:hover { border-color: #667eea; color: #667eea; }
        
        @media (max-width: 768px) {
            .main-content { grid-template-columns: 1fr; gap: 20px; }
            .container { padding: 24px; }
            .logo { font-size: 3rem; }
            h1 { font-size: 1.8rem; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">🎵</div>
            <h1>YesPlayMusic</h1>
            <p class="subtitle">高颜值的第三方网易云音乐播放器</p>
        </div>
        
        <div class="main-content">
            <div class="player-section">
                <h2 class="section-title">🎶 音乐播放器</h2>
                <div class="music-player">
                    <div class="album-art">🎵</div>
                    <div class="song-info">
                        <div class="song-title">正在连接音乐服务...</div>
                        <div class="artist-name">YesPlayMusic</div>
                    </div>
                    <div class="controls">
                        <button class="control-btn">⏮️</button>
                        <button class="control-btn play-btn" onclick="togglePlay()">▶️</button>
                        <button class="control-btn">⏭️</button>
                    </div>
                    <div class="progress-bar">
                        <div class="progress"></div>
                    </div>
                    <div class="time-info">
                        <span>0:00</span>
                        <span>3:45</span>
                    </div>
                </div>
            </div>
            
            <div class="api-section">
                <h2 class="section-title">🔗 服务状态</h2>
                <div class="api-status">
                    <div class="status-indicator"></div>
                    <div class="api-info">
                        <div><strong>API状态:</strong> <span id="api-status">检查中...</span></div>
                        <div><strong>服务地址:</strong> <span id="api-url">配置中...</span></div>
                    </div>
                </div>
                <div style="font-size: 0.85rem; color: #666; line-height: 1.6;">
                    <p><strong>功能说明:</strong></p>
                    <p>• 支持网易云音乐完整功能</p>
                    <p>• 高品质音乐播放</p>
                    <p>• 个性化推荐</p>
                    <p>• 歌词显示</p>
                </div>
            </div>
        </div>
        
        <div class="action-buttons">
            <button onclick="location.reload()" class="btn btn-primary">🔄 刷新服务</button>
            <a href="/api/" target="_blank" class="btn btn-secondary">🔧 检查API</a>
            <button onclick="testConnection()" class="btn btn-secondary">📡 测试连接</button>
            <a href="https://music.qier222.com/" target="_blank" class="btn btn-secondary">🌐 官方Demo</a>
        </div>
    </div>
    
    <script>
        let isPlaying = false;
        let progress = 35;
        
        function togglePlay() {
            const playBtn = document.querySelector('.play-btn');
            isPlaying = !isPlaying;
            playBtn.textContent = isPlaying ? '⏸️' : '▶️';
            if (isPlaying) startProgress();
        }
        
        function startProgress() {
            if (!isPlaying) return;
            const progressBar = document.querySelector('.progress');
            progress += 1;
            if (progress > 100) progress = 0;
            progressBar.style.width = progress + '%';
            setTimeout(startProgress, 1000);
        }
        
        async function checkAPI() {
            const statusEl = document.getElementById('api-status');
            const urlEl = document.getElementById('api-url');
            
            try {
                // 首先读取配置文件
                const configResponse = await fetch('/config.json');
                if (configResponse.ok) {
                    const config = await configResponse.json();
                    const actualApiUrl = config.apiUrl || config.proxyApiUrl || '/api';
                    urlEl.textContent = config.apiUrl;
                    
                    // 测试API连接 - 先测试代理端点
                    const testResponse = await fetch('/netease-api-test', { 
                        method: 'GET',
                        timeout: 8000
                    });
                    
                    if (testResponse.ok) {
                        statusEl.textContent = '✅ 连接正常';
                        statusEl.style.color = '#48bb78';
                        document.querySelector('.song-title').textContent = '🎵 API服务正常';
                        return true;
                    } else {
                        // 如果代理失败，尝试直接测试本地API端点
                        const localResponse = await fetch('/api/', { 
                            method: 'GET',
                            timeout: 5000
                        });
                        
                        if (localResponse.ok || localResponse.status === 404) {
                            statusEl.textContent = '⚠️ 部分功能可用';
                            statusEl.style.color = '#ed8936';
                            document.querySelector('.song-title').textContent = '⚠️ API代理异常';
                        } else {
                            statusEl.textContent = '❌ 服务异常';
                            statusEl.style.color = '#e53e3e';
                        }
                    }
                } else {
                    statusEl.textContent = '❌ 配置读取失败';
                    statusEl.style.color = '#e53e3e';
                    urlEl.textContent = '配置异常';
                }
            } catch (error) {
                statusEl.textContent = '❌ 连接失败';
                statusEl.style.color = '#e53e3e';
                urlEl.textContent = '网络异常';
                console.error('API检查失败:', error);
            }
            return false;
        }
        
        async function testConnection() {
            document.getElementById('api-status').textContent = '🔄 测试中...';
            await new Promise(resolve => setTimeout(resolve, 1000));
            await checkAPI();
        }
        
        document.addEventListener('DOMContentLoaded', () => {
            checkAPI();
            setInterval(checkAPI, 30000);
        });
    </script>
</body>
</html>
HTMLEOF

# 创建配置文件
RUN echo '{"apiUrl":"/api","version":"1.0.0","status":"ready"}' > /usr/share/nginx/html/config.json

# 复制配置文件
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

CMD ["/run.sh"]