ARG BUILD_ARCH
FROM nginx:alpine

# 安装工具
RUN apk add --no-cache supervisor jq bash curl

# 创建YesPlayMusic代理页面
RUN cat > /usr/share/nginx/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>YesPlayMusic - Home Assistant</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🎵</text></svg>">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; overflow: hidden; }
        
        .header {
            position: fixed; top: 0; left: 0; right: 0; height: 60px; z-index: 1000;
            background: rgba(255, 255, 255, 0.95); backdrop-filter: blur(10px);
            display: flex; align-items: center; justify-content: space-between;
            padding: 0 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .logo { display: flex; align-items: center; gap: 10px; font-weight: 600; color: #333; }
        .logo-icon { font-size: 1.5rem; }
        
        .status { display: flex; align-items: center; gap: 15px; font-size: 0.9rem; }
        .api-status { padding: 4px 12px; border-radius: 15px; font-size: 0.8rem; font-weight: 500; }
        .api-status.success { background: #d1fae5; color: #065f46; }
        .api-status.error { background: #fee2e2; color: #991b1b; }
        .api-status.warning { background: #fef3c7; color: #92400e; }
        
        .controls { display: flex; gap: 10px; }
        .btn {
            padding: 6px 12px; border: none; border-radius: 15px; cursor: pointer;
            font-size: 0.8rem; text-decoration: none; transition: all 0.2s;
        }
        .btn-primary { background: #3b82f6; color: white; }
        .btn-primary:hover { background: #2563eb; }
        .btn-secondary { background: #f3f4f6; color: #374151; }
        .btn-secondary:hover { background: #e5e7eb; }
        
        #music-frame {
            position: fixed; top: 60px; left: 0; width: 100%; height: calc(100vh - 60px);
            border: none; background: white;
        }
        
        .loading {
            position: fixed; top: 60px; left: 0; width: 100%; height: calc(100vh - 60px);
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex; align-items: center; justify-content: center;
            color: white; z-index: 999;
        }
        
        .loading-content { text-align: center; }
        .spinner {
            width: 50px; height: 50px; margin: 20px auto;
            border: 3px solid rgba(255,255,255,0.3);
            border-top: 3px solid white; border-radius: 50%;
            animation: spin 1s linear infinite;
        }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
        
        .error-page {
            position: fixed; top: 60px; left: 0; width: 100%; height: calc(100vh - 60px);
            background: #f9fafb; display: none; align-items: center; justify-content: center;
        }
        .error-content {
            text-align: center; max-width: 500px; padding: 40px;
            background: white; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }
        .error-content h2 { color: #374151; margin-bottom: 15px; }
        .error-content p { color: #6b7280; margin-bottom: 25px; line-height: 1.6; }
        .error-buttons { display: flex; gap: 15px; justify-content: center; flex-wrap: wrap; }
        .error-buttons .btn { padding: 12px 24px; font-size: 0.9rem; }
    </style>
</head>
<body>
    <div class="header">
        <div class="logo">
            <span class="logo-icon">🎵</span>
            <span>YesPlayMusic</span>
        </div>
        <div class="status">
            <div id="api-status" class="api-status warning">检查中...</div>
            <div style="font-size: 0.8rem; color: #6b7280;">
                API: <span id="api-url">配置中...</span>
            </div>
        </div>
        <div class="controls">
            <button onclick="reloadMusic()" class="btn btn-secondary">🔄</button>
            <button onclick="toggleFullscreen()" class="btn btn-secondary">⛶</button>
            <a href="/api/" target="_blank" class="btn btn-secondary">🔧</a>
        </div>
    </div>
    
    <div class="loading" id="loading">
        <div class="loading-content">
            <div class="spinner"></div>
            <h3>正在加载 YesPlayMusic</h3>
            <p style="margin-top: 10px; opacity: 0.8;">连接到音乐服务...</p>
        </div>
    </div>
    
    <div class="error-page" id="error-page">
        <div class="error-content">
            <h2>🎵 YesPlayMusic</h2>
            <p>正在为您准备最佳的音乐体验。如果加载时间较长，您也可以直接访问官方演示站点。</p>
            <div class="error-buttons">
                <button onclick="reloadMusic()" class="btn btn-primary">🔄 重新加载</button>
                <a href="https://music.qier222.com/" target="_blank" class="btn btn-secondary">🌐 官方演示</a>
                <button onclick="showSimplePlayer()" class="btn btn-secondary">🎵 简化版</button>
            </div>
        </div>
    </div>
    
    <iframe id="music-frame" style="display: none;"></iframe>
    
    <script>
        let apiUrl = '/api';
        let originalApiUrl = '';
        let retryCount = 0;
        const maxRetries = 3;
        
        // 初始化
        async function init() {
            await loadConfig();
            await checkAPI();
            loadYesPlayMusic();
        }
        
        // 加载配置
        async function loadConfig() {
            try {
                const response = await fetch('/config.json');
                if (response.ok) {
                    const config = await response.json();
                    originalApiUrl = config.apiUrl || '/api';
                    apiUrl = '/api'; // 使用代理地址
                    document.getElementById('api-url').textContent = originalApiUrl;
                }
            } catch (error) {
                console.log('配置加载失败:', error);
            }
        }
        
        // 检查API状态
        async function checkAPI() {
            const statusEl = document.getElementById('api-status');
            
            try {
                // 测试API连接
                const response = await fetch('/netease-api-test', { 
                    method: 'GET',
                    timeout: 5000 
                });
                
                if (response.ok) {
                    statusEl.textContent = '✅ 已连接';
                    statusEl.className = 'api-status success';
                    return true;
                } else {
                    statusEl.textContent = '⚠️ 异常';
                    statusEl.className = 'api-status warning';
                }
            } catch (error) {
                statusEl.textContent = '❌ 失败';
                statusEl.className = 'api-status error';
            }
            return false;
        }
        
        // 加载YesPlayMusic
        function loadYesPlayMusic() {
            const frame = document.getElementById('music-frame');
            const loading = document.getElementById('loading');
            
            // 尝试加载官方demo
            frame.src = 'https://music.qier222.com/';
            
            frame.onload = function() {
                loading.style.display = 'none';
                frame.style.display = 'block';
                
                // 尝试配置API
                setTimeout(() => {
                    try {
                        frame.contentWindow.postMessage({
                            type: 'CONFIGURE_API',
                            apiUrl: apiUrl,
                            originalUrl: originalApiUrl
                        }, '*');
                    } catch (e) {
                        console.log('API配置失败:', e);
                    }
                }, 2000);
            };
            
            frame.onerror = function() {
                retryCount++;
                if (retryCount < maxRetries) {
                    setTimeout(() => loadYesPlayMusic(), 3000);
                } else {
                    loading.style.display = 'none';
                    document.getElementById('error-page').style.display = 'flex';
                }
            };
            
            // 超时处理
            setTimeout(() => {
                if (frame.style.display === 'none') {
                    frame.onerror();
                }
            }, 15000);
        }
        
        // 重新加载音乐
        function reloadMusic() {
            retryCount = 0;
            document.getElementById('loading').style.display = 'flex';
            document.getElementById('error-page').style.display = 'none';
            document.getElementById('music-frame').style.display = 'none';
            loadYesPlayMusic();
        }
        
        // 全屏切换
        function toggleFullscreen() {
            const header = document.querySelector('.header');
            const frame = document.getElementById('music-frame');
            
            if (header.style.display === 'none') {
                header.style.display = 'flex';
                frame.style.top = '60px';
                frame.style.height = 'calc(100vh - 60px)';
            } else {
                header.style.display = 'none';
                frame.style.top = '0';
                frame.style.height = '100vh';
            }
        }
        
        // 显示简化播放器
        function showSimplePlayer() {
            location.href = '/simple/';
        }
        
        // 监听API状态变化
        setInterval(checkAPI, 30000);
        
        // 启动
        document.addEventListener('DOMContentLoaded', init);
    </script>
</body>
</html>
EOF

# 创建简化播放器页面
RUN mkdir -p /usr/share/nginx/html/simple && \
    cat > /usr/share/nginx/html/simple/index.html << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>YesPlayMusic - 简化版</title>
    <style>
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0; padding: 20px; min-height: 100vh;
        }
        .container {
            max-width: 800px; margin: 0 auto; 
            background: rgba(255,255,255,0.95); backdrop-filter: blur(20px);
            border-radius: 20px; padding: 30px; box-shadow: 0 20px 60px rgba(0,0,0,0.2);
        }
        .header { text-align: center; margin-bottom: 30px; }
        .logo { font-size: 3rem; margin-bottom: 10px; }
        h1 { color: #2d3748; font-size: 2rem; font-weight: 300; margin-bottom: 10px; }
        .subtitle { color: #667eea; margin-bottom: 30px; }
        .back-btn {
            position: absolute; top: 20px; left: 20px;
            padding: 10px 20px; background: rgba(255,255,255,0.2);
            color: white; text-decoration: none; border-radius: 15px;
            transition: background 0.3s;
        }
        .back-btn:hover { background: rgba(255,255,255,0.3); }
        .message {
            text-align: center; padding: 40px;
            background: #f8fafc; border-radius: 15px;
            color: #4a5568; line-height: 1.8;
        }
        .actions {
            display: flex; gap: 15px; justify-content: center; margin-top: 30px;
            flex-wrap: wrap;
        }
        .btn {
            padding: 12px 24px; border: none; border-radius: 20px;
            cursor: pointer; text-decoration: none; font-weight: 500;
            transition: all 0.3s; display: inline-flex; align-items: center; gap: 8px;
        }
        .btn-primary { background: linear-gradient(135deg, #667eea, #764ba2); color: white; }
        .btn-secondary { background: white; color: #4a5568; border: 2px solid #e2e8f0; }
        .btn:hover { transform: translateY(-2px); }
    </style>
</head>
<body>
    <a href="/" class="back-btn">← 返回</a>
    
    <div class="container">
        <div class="header">
            <div class="logo">🎵</div>
            <h1>YesPlayMusic</h1>
            <p class="subtitle">高颜值的第三方网易云播放器</p>
        </div>
        
        <div class="message">
            <h3 style="margin-bottom: 20px;">🎶 音乐服务已就绪</h3>
            <p>
                YesPlayMusic服务正在运行，API代理已配置完成。<br>
                您现在可以通过以下方式访问完整的音乐功能：
            </p>
            
            <div class="actions">
                <a href="/" class="btn btn-primary">🔄 重新加载完整版</a>
                <a href="https://music.qier222.com/" target="_blank" class="btn btn-secondary">🌐 官方演示</a>
                <a href="/api/" target="_blank" class="btn btn-secondary">🔧 API状态</a>
            </div>
            
            <div style="margin-top: 30px; font-size: 0.9rem; color: #718096;">
                <p><strong>提示：</strong></p>
                <p>• 如果完整版加载较慢，可以直接访问官方演示站点</p>
                <p>• API代理已配置，支持完整的网易云音乐功能</p>
                <p>• 建议使用现代浏览器以获得最佳体验</p>
            </div>
        </div>
    </div>
</body>
</html>
EOF

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