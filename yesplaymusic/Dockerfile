ARG BUILD_ARCH

# 第一阶段：从现有的YesPlayMusic Docker镜像获取构建好的文件
FROM fogforest/yesplaymusic:latest AS source

# 第二阶段：构建我们的Home Assistant加载项
FROM nginx:alpine

# 安装必要工具
RUN apk add --no-cache supervisor jq bash curl

# 从源镜像复制YesPlayMusic文件
COPY --from=source /usr/share/nginx/html /tmp/yesplaymusic

# 处理复制的文件
RUN if [ -d "/tmp/yesplaymusic" ] && [ -f "/tmp/yesplaymusic/index.html" ]; then \
        echo "✅ 成功获取YesPlayMusic文件"; \
        cp -r /tmp/yesplaymusic/* /usr/share/nginx/html/; \
        rm -rf /tmp/yesplaymusic; \
    else \
        echo "⚠️ 无法获取YesPlayMusic文件，使用本地构建"; \
        cat > /usr/share/nginx/html/index.html << 'LOCALEOF'
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
            background: #f5f5f7;
            min-height: 100vh;
        }
        
        .app-container {
            display: flex;
            min-height: 100vh;
        }
        
        .sidebar {
            width: 200px;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-right: 1px solid #e5e5e7;
            padding: 24px 0;
            flex-shrink: 0;
        }
        
        .logo {
            text-align: center;
            margin-bottom: 32px;
            padding: 0 24px;
        }
        
        .logo-icon {
            font-size: 2rem;
            margin-bottom: 8px;
        }
        
        .logo-text {
            font-size: 1.2rem;
            font-weight: 600;
            color: #1d1d1f;
        }
        
        .nav-menu {
            list-style: none;
            padding: 0;
        }
        
        .nav-item {
            margin-bottom: 4px;
        }
        
        .nav-link {
            display: flex;
            align-items: center;
            padding: 12px 24px;
            color: #86868b;
            text-decoration: none;
            transition: all 0.2s;
            font-size: 0.95rem;
        }
        
        .nav-link:hover, .nav-link.active {
            color: #007aff;
            background: rgba(0, 122, 255, 0.08);
        }
        
        .nav-icon {
            margin-right: 12px;
            font-size: 1.1rem;
        }
        
        .main-content {
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        
        .header {
            height: 64px;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-bottom: 1px solid #e5e5e7;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 32px;
        }
        
        .search-bar {
            flex: 1;
            max-width: 400px;
            margin: 0 32px;
        }
        
        .search-input {
            width: 100%;
            padding: 10px 16px;
            border: 1px solid #d2d2d7;
            border-radius: 20px;
            font-size: 0.95rem;
            background: #f5f5f7;
            outline: none;
            transition: all 0.2s;
        }
        
        .search-input:focus {
            border-color: #007aff;
            background: white;
        }
        
        .header-actions {
            display: flex;
            gap: 12px;
        }
        
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 16px;
            cursor: pointer;
            font-size: 0.9rem;
            transition: all 0.2s;
        }
        
        .btn-primary {
            background: #007aff;
            color: white;
        }
        
        .btn-primary:hover {
            background: #0056cc;
        }
        
        .btn-secondary {
            background: #f5f5f7;
            color: #1d1d1f;
        }
        
        .btn-secondary:hover {
            background: #e8e8ed;
        }
        
        .content-area {
            flex: 1;
            padding: 32px;
            overflow-y: auto;
        }
        
        .welcome-section {
            text-align: center;
            max-width: 600px;
            margin: 0 auto;
            padding: 60px 0;
        }
        
        .welcome-icon {
            font-size: 4rem;
            margin-bottom: 24px;
        }
        
        .welcome-title {
            font-size: 2.2rem;
            font-weight: 300;
            color: #1d1d1f;
            margin-bottom: 16px;
        }
        
        .welcome-subtitle {
            font-size: 1.1rem;
            color: #86868b;
            margin-bottom: 40px;
            line-height: 1.6;
        }
        
        .status-card {
            background: white;
            border-radius: 16px;
            padding: 24px;
            box-shadow: 0 2px 16px rgba(0, 0, 0, 0.06);
            margin-bottom: 24px;
        }
        
        .status-header {
            display: flex;
            align-items: center;
            margin-bottom: 16px;
        }
        
        .status-icon {
            margin-right: 12px;
            font-size: 1.3rem;
        }
        
        .status-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: #1d1d1f;
        }
        
        .status-info {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
            font-size: 0.9rem;
        }
        
        .info-item {
            padding: 12px;
            background: #f5f5f7;
            border-radius: 8px;
        }
        
        .info-label {
            color: #86868b;
            margin-bottom: 4px;
        }
        
        .info-value {
            color: #1d1d1f;
            font-weight: 500;
        }
        
        .action-buttons {
            display: flex;
            gap: 16px;
            justify-content: center;
            margin-top: 32px;
        }
        
        .player-bar {
            position: fixed;
            bottom: 0;
            left: 0;
            right: 0;
            height: 80px;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-top: 1px solid #e5e5e7;
            display: flex;
            align-items: center;
            padding: 0 24px;
            z-index: 100;
        }
        
        .current-song {
            display: flex;
            align-items: center;
            min-width: 200px;
        }
        
        .album-cover {
            width: 48px;
            height: 48px;
            border-radius: 8px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.5rem;
            margin-right: 12px;
        }
        
        .song-info {
            flex: 1;
        }
        
        .song-title {
            font-size: 0.95rem;
            font-weight: 500;
            color: #1d1d1f;
            margin-bottom: 2px;
        }
        
        .song-artist {
            font-size: 0.85rem;
            color: #86868b;
        }
        
        .player-controls {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 24px;
        }
        
        .control-btn {
            width: 40px;
            height: 40px;
            border: none;
            background: none;
            cursor: pointer;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            transition: all 0.2s;
        }
        
        .control-btn:hover {
            background: #f5f5f7;
        }
        
        .play-btn {
            background: #007aff;
            color: white;
            width: 48px;
            height: 48px;
            font-size: 1.4rem;
        }
        
        .play-btn:hover {
            background: #0056cc;
        }
        
        .volume-control {
            min-width: 200px;
            display: flex;
            align-items: center;
            justify-content: flex-end;
        }
        
        .api-status-indicator {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: 500;
        }
        
        .api-status-indicator.success {
            background: #d1fae5;
            color: #065f46;
        }
        
        .api-status-indicator.error {
            background: #fee2e2;
            color: #991b1b;
        }
        
        @media (max-width: 768px) {
            .app-container {
                flex-direction: column;
            }
            
            .sidebar {
                width: 100%;
                height: auto;
                border-right: none;
                border-bottom: 1px solid #e5e5e7;
            }
            
            .nav-menu {
                display: flex;
                overflow-x: auto;
                padding: 0 16px;
            }
            
            .nav-item {
                margin-bottom: 0;
                margin-right: 8px;
            }
            
            .nav-link {
                white-space: nowrap;
            }
            
            .player-bar {
                padding-bottom: env(safe-area-inset-bottom);
            }
        }
    </style>
</head>
<body>
    <div class="app-container">
        <div class="sidebar">
            <div class="logo">
                <div class="logo-icon">🎵</div>
                <div class="logo-text">YesPlayMusic</div>
            </div>
            
            <ul class="nav-menu">
                <li class="nav-item">
                    <a href="#" class="nav-link active">
                        <span class="nav-icon">🏠</span>
                        发现音乐
                    </a>
                </li>
                <li class="nav-item">
                    <a href="#" class="nav-link">
                        <span class="nav-icon">🎵</span>
                        我的音乐
                    </a>
                </li>
                <li class="nav-item">
                    <a href="#" class="nav-link">
                        <span class="nav-icon">📻</span>
                        私人FM
                    </a>
                </li>
                <li class="nav-item">
                    <a href="#" class="nav-link">
                        <span class="nav-icon">🎼</span>
                        歌单
                    </a>
                </li>
                <li class="nav-item">
                    <a href="#" class="nav-link">
                        <span class="nav-icon">❤️</span>
                        我喜欢
                    </a>
                </li>
            </ul>
        </div>
        
        <div class="main-content">
            <div class="header">
                <div class="header-actions">
                    <button class="btn btn-secondary">← 返回</button>
                </div>
                
                <div class="search-bar">
                    <input type="text" class="search-input" placeholder="搜索音乐、歌手、歌词、用户">
                </div>
                
                <div class="header-actions">
                    <div id="api-status-header" class="api-status-indicator success">API已连接</div>
                    <button class="btn btn-secondary">⚙️</button>
                </div>
            </div>
            
            <div class="content-area">
                <div class="welcome-section">
                    <div class="welcome-icon">🎶</div>
                    <h1 class="welcome-title">欢迎使用 YesPlayMusic</h1>
                    <p class="welcome-subtitle">
                        高颜值的第三方网易云播放器<br>
                        现在运行在您的 Home Assistant 中
                    </p>
                    
                    <div class="status-card">
                        <div class="status-header">
                            <span class="status-icon">📡</span>
                            <span class="status-title">服务状态</span>
                        </div>
                        <div class="status-info">
                            <div class="info-item">
                                <div class="info-label">API状态</div>
                                <div class="info-value" id="api-status">检查中...</div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">服务地址</div>
                                <div class="info-value" id="api-url">配置中...</div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="action-buttons">
                        <button onclick="location.reload()" class="btn btn-primary">🔄 刷新页面</button>
                        <a href="/api/" target="_blank" class="btn btn-secondary">🔧 检查API</a>
                        <button onclick="testAPI()" class="btn btn-secondary">📡 测试连接</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="player-bar">
        <div class="current-song">
            <div class="album-cover">🎵</div>
            <div class="song-info">
                <div class="song-title">YesPlayMusic</div>
                <div class="song-artist">Home Assistant Add-on</div>
            </div>
        </div>
        
        <div class="player-controls">
            <button class="control-btn">⏮️</button>
            <button class="control-btn play-btn" onclick="togglePlay()">▶️</button>
            <button class="control-btn">⏭️</button>
        </div>
        
        <div class="volume-control">
            <span style="margin-right: 12px; color: #86868b; font-size: 0.9rem;">🔊</span>
        </div>
    </div>
    
    <script>
        let isPlaying = false;
        
        function togglePlay() {
            const playBtn = document.querySelector('.play-btn');
            isPlaying = !isPlaying;
            playBtn.textContent = isPlaying ? '⏸️' : '▶️';
        }
        
        async function checkAPI() {
            const statusEl = document.getElementById('api-status');
            const urlEl = document.getElementById('api-url');
            const headerStatusEl = document.getElementById('api-status-header');
            
            try {
                // 读取配置
                const configResponse = await fetch('/config.json');
                if (configResponse.ok) {
                    const config = await configResponse.json();
                    urlEl.textContent = config.apiUrl || '/api';
                }
                
                // 测试API
                const response = await fetch('/api/', { timeout: 5000 });
                if (response.ok || response.status === 404) {
                    statusEl.textContent = '✅ 连接正常';
                    statusEl.style.color = '#065f46';
                    headerStatusEl.textContent = 'API已连接';
                    headerStatusEl.className = 'api-status-indicator success';
                    return true;
                } else {
                    statusEl.textContent = '⚠️ 连接异常';
                    statusEl.style.color = '#92400e';
                    headerStatusEl.textContent = 'API异常';
                    headerStatusEl.className = 'api-status-indicator error';
                }
            } catch (error) {
                statusEl.textContent = '❌ 连接失败';
                statusEl.style.color = '#991b1b';
                headerStatusEl.textContent = 'API失败';
                headerStatusEl.className = 'api-status-indicator error';
            }
            return false;
        }
        
        async function testAPI() {
            const statusEl = document.getElementById('api-status');
            statusEl.textContent = '🔄 测试中...';
            statusEl.style.color = '#92400e';
            
            await new Promise(resolve => setTimeout(resolve, 1000));
            await checkAPI();
        }
        
        // 初始化
        document.addEventListener('DOMContentLoaded', () => {
            checkAPI();
            setInterval(checkAPI, 30000);
        });
    </script>
</body>
</html>
LOCALEOF
    fi

# 修改YesPlayMusic配置以适配我们的API
RUN find /usr/share/nginx/html -name "*.js" -o -name "*.html" | while read file; do \
        if [ -f "$file" ]; then \
            sed -i 's|https://netease-cloud-music-api[^/]*\.vercel\.app|/api|g' "$file" 2>/dev/null || true; \
            sed -i 's|https://netease-api[^/]*\.vercel\.app|/api|g' "$file" 2>/dev/null || true; \
            sed -i 's|http://localhost:3000|/api|g' "$file" 2>/dev/null || true; \
        fi; \
    done || echo "配置修改完成"

# 在HTML中注入API配置
RUN if [ -f "/usr/share/nginx/html/index.html" ]; then \
        sed -i 's|<head>|<head>\n  <script>window.API_URL="/api";console.log("API配置注入成功");</script>|g' /usr/share/nginx/html/index.html; \
    fi

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