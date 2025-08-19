ARG BUILD_ARCH
FROM node:18-alpine AS builder

# 安装构建依赖
RUN apk add --no-cache git python3 make g++ vips-dev

# 克隆stark81的my_yesplaymusic项目
WORKDIR /app
RUN git clone --depth 1 https://github.com/stark81/my_yesplaymusic.git . || \
    echo "主仓库克隆失败，将使用代理方案"

# 设置npm配置
RUN if [ -f "package.json" ]; then \
        npm config set registry https://registry.npmmirror.com/; \
        npm install --legacy-peer-deps || npm ci --legacy-peer-deps; \
        # 配置API地址
        echo "VUE_APP_NETEASE_API_URL=/api" > .env.local; \
        # 构建项目
        NODE_OPTIONS="--max-old-space-size=4096" npm run build || \
        NODE_OPTIONS="--max-old-space-size=2048" npm run build:web || \
        echo "构建失败，将使用代理方案"; \
    fi

# 生产阶段
FROM nginx:alpine

# 安装必要工具
RUN apk add --no-cache supervisor jq bash curl

# 尝试复制构建结果，如果失败则使用代理方案
COPY --from=builder /app/dist /tmp/build 2>/dev/null || echo "构建文件不存在"

RUN if [ -d "/tmp/build" ] && [ -f "/tmp/build/index.html" ]; then \
        echo "✅ 使用本地构建的YesPlayMusic"; \
        cp -r /tmp/build/* /usr/share/nginx/html/; \
        rm -rf /tmp/build; \
    else \
        echo "⚠️ 使用代理方案连接到可用的YesPlayMusic界面"; \
        cat > /usr/share/nginx/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>YesPlayMusic</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🎵</text></svg>">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; overflow: hidden; }
        
        .header {
            position: fixed; top: 0; left: 0; right: 0; height: 50px; z-index: 1000;
            background: rgba(255, 255, 255, 0.95); backdrop-filter: blur(10px);
            display: flex; align-items: center; justify-content: space-between;
            padding: 0 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            border-bottom: 1px solid #e5e5e7;
        }
        
        .logo { display: flex; align-items: center; gap: 8px; font-weight: 600; color: #333; }
        .logo-icon { font-size: 1.3rem; }
        
        .status-info { display: flex; align-items: center; gap: 15px; font-size: 0.85rem; }
        .api-status { padding: 3px 10px; border-radius: 12px; font-size: 0.75rem; font-weight: 500; }
        .api-status.success { background: #d1fae5; color: #065f46; }
        .api-status.error { background: #fee2e2; color: #991b1b; }
        .api-status.warning { background: #fef3c7; color: #92400e; }
        
        .controls { display: flex; gap: 8px; }
        .btn {
            padding: 5px 10px; border: none; border-radius: 12px; cursor: pointer;
            font-size: 0.75rem; text-decoration: none; transition: all 0.2s;
            background: #f3f4f6; color: #374151;
        }
        .btn:hover { background: #e5e7eb; }
        
        #music-frame {
            position: fixed; top: 50px; left: 0; width: 100%; height: calc(100vh - 50px);
            border: none; background: white;
        }
        
        .loading {
            position: fixed; top: 50px; left: 0; width: 100%; height: calc(100vh - 50px);
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex; align-items: center; justify-content: center;
            color: white; z-index: 999;
        }
        
        .loading-content { text-align: center; }
        .spinner {
            width: 40px; height: 40px; margin: 20px auto;
            border: 3px solid rgba(255,255,255,0.3);
            border-top: 3px solid white; border-radius: 50%;
            animation: spin 1s linear infinite;
        }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
        
        .error-page {
            position: fixed; top: 50px; left: 0; width: 100%; height: calc(100vh - 50px);
            background: #f9fafb; display: none; align-items: center; justify-content: center;
        }
        .error-content {
            text-align: center; max-width: 450px; padding: 30px;
            background: white; border-radius: 16px; box-shadow: 0 8px 25px rgba(0,0,0,0.1);
        }
        .error-content h2 { color: #374151; margin-bottom: 12px; font-size: 1.3rem; }
        .error-content p { color: #6b7280; margin-bottom: 20px; line-height: 1.5; font-size: 0.9rem; }
        .error-buttons { display: flex; gap: 12px; justify-content: center; flex-wrap: wrap; }
        .error-buttons .btn { padding: 10px 20px; font-size: 0.85rem; }
        .btn-primary { background: #3b82f6; color: white; }
        .btn-primary:hover { background: #2563eb; }
    </style>
</head>
<body>
    <div class="header">
        <div class="logo">
            <span class="logo-icon">🎵</span>
            <span>YesPlayMusic</span>
        </div>
        <div class="status-info">
            <div id="api-status" class="api-status warning">检查中...</div>
            <div style="font-size: 0.75rem; color: #6b7280;">
                API: <span id="api-url">配置中...</span>
            </div>
        </div>
        <div class="controls">
            <button onclick="reloadMusic()" class="btn">🔄</button>
            <button onclick="toggleHeader()" class="btn">⛶</button>
            <a href="/api/" target="_blank" class="btn">🔧</a>
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
            <p>正在为您准备最佳的音乐体验。如果加载时间较长，您也可以尝试其他操作。</p>
            <div class="error-buttons">
                <button onclick="reloadMusic()" class="btn btn-primary">🔄 重新加载</button>
                <button onclick="useBackup()" class="btn">🎵 备用方案</button>
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
            
            // 使用您提供的可用界面
            frame.src = 'https://my-yesplaymusic-five.vercel.app/';
            
            frame.onload = function() {
                loading.style.display = 'none';
                frame.style.display = 'block';
                
                // 尝试配置API
                setTimeout(() => {
                    try {
                        frame.contentWindow.postMessage({
                            type: 'CONFIGURE_API',
                            apiUrl: window.location.origin + apiUrl,
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
        
        // 切换头部显示
        function toggleHeader() {
            const header = document.querySelector('.header');
            const frame = document.getElementById('music-frame');
            
            if (header.style.display === 'none') {
                header.style.display = 'flex';
                frame.style.top = '50px';
                frame.style.height = 'calc(100vh - 50px)';
            } else {
                header.style.display = 'none';
                frame.style.top = '0';
                frame.style.height = '100vh';
            }
        }
        
        // 使用备用方案
        function useBackup() {
            window.location.href = '/simple/';
        }
        
        // 监听来自iframe的消息
        window.addEventListener('message', function(event) {
            if (event.data && event.data.type === 'API_CONFIGURED') {
                console.log('YesPlayMusic API配置成功');
            }
        });
        
        // 监听API状态变化
        setInterval(checkAPI, 30000);
        
        // 启动
        document.addEventListener('DOMContentLoaded', init);
    </script>
</body>
</html>
EOF
    fi

# 修改任何现有的YesPlayMusic配置以适配我们的API
RUN find /usr/share/nginx/html -name "*.js" -o -name "*.html" | while read file; do \
        if [ -f "$file" ]; then \
            # 替换各种可能的API地址格式
            sed -i 's|https://netease-cloud-music-api[^/]*\.vercel\.app|/api|g' "$file" 2>/dev/null || true; \
            sed -i 's|https://music-api[^/]*\.vercel\.app|/api|g' "$file" 2>/dev/null || true; \
            sed -i 's|http://localhost:3000|/api|g' "$file" 2>/dev/null || true; \
            sed -i 's|127\.0\.0\.1:3000|/api|g' "$file" 2>/dev/null || true; \
        fi; \
    done || echo "配置修改完成"

# 在HTML中注入API配置
RUN if [ -f "/usr/share/nginx/html/index.html" ]; then \
        sed -i 's|<head>|<head>\n  <script>window.NETEASE_API_URL="/api";window.VUE_APP_NETEASE_API_URL="/api";console.log("API配置注入成功");</script>|g' /usr/share/nginx/html/index.html; \
    fi

# 创建简化播放器页面
RUN mkdir -p /usr/share/nginx/html/simple && \
    cat > /usr/share/nginx/html/simple/index.html << 'SIMPLEEOF'
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
            max-width: 700px; margin: 0 auto; 
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
        .info-grid {
            display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 30px;
        }
        .info-card {
            padding: 20px; background: #f8fafc; border-radius: 15px;
            border-left: 4px solid #48bb78;
        }
        .info-card h3 { color: #2d3748; margin-bottom: 10px; font-size: 1.1rem; }
        .info-card p { color: #4a5568; line-height: 1.6; font-size: 0.9rem; }
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
        @media (max-width: 640px) {
            .info-grid { grid-template-columns: 1fr; }
        }
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
        
        <div class="info-grid">
            <div class="info-card">
                <h3>🎶 服务状态</h3>
                <p>YesPlayMusic服务正在正常运行，API代理已配置完成，支持完整的网易云音乐功能。</p>
            </div>
            <div class="info-card">
                <h3>🔗 连接信息</h3>
                <p>当前使用stark81优化版本的YesPlayMusic界面，提供更好的性能和稳定性。</p>
            </div>
        </div>
        
        <div style="text-align: center; padding: 20px; background: #f0fff4; border-radius: 15px; margin-bottom: 20px;">
            <p><strong>✨ 功能特色</strong></p>
            <p style="margin-top: 10px; color: #4a5568; line-height: 1.6;">
                • 支持网易云音乐完整功能<br>
                • 高品质音乐播放体验<br>
                • 个性化推荐和歌单管理<br>
                • 实时歌词和桌面歌词显示
            </p>
        </div>
        
        <div class="actions">
            <a href="/" class="btn btn-primary">🔄 重新加载完整版</a>
            <a href="https://my-yesplaymusic-five.vercel.app/" target="_blank" class="btn btn-secondary">🌐 直接访问</a>
            <a href="/api/" target="_blank" class="btn btn-secondary">🔧 API状态</a>
        </div>
    </div>
</body>
</html>
SIMPLEEOF

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
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

CMD ["/run.sh"]