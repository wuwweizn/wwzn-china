FROM alpine:latest

# 安装必要的系统包
RUN apk add --no-cache \
        curl \
        bash \
        jq \
        nginx \
        supervisor \
        nodejs \
        npm \
        git

# 创建必要的目录
RUN mkdir -p /var/www/html \
    /var/log/nginx \
    /var/lib/nginx/tmp \
    /run/nginx \
    /var/log/supervisor \
    /etc/supervisor/conf.d

# 安装yarn
RUN npm install -g yarn

# 创建备用HTML页面
RUN cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>YesPlayMusic</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            color: white;
            padding: 1rem;
        }
        .container {
            text-align: center;
            max-width: 600px;
            padding: 2rem;
            background: rgba(255,255,255,0.1);
            border-radius: 20px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0,0,0,0.1);
        }
        .logo { font-size: 5rem; margin-bottom: 1rem; }
        .title { 
            font-size: 3rem; 
            margin-bottom: 1rem; 
            font-weight: 300; 
            text-shadow: 0 2px 10px rgba(0,0,0,0.3);
        }
        .subtitle { 
            font-size: 1.3rem; 
            opacity: 0.9; 
            margin-bottom: 2rem; 
            line-height: 1.5;
        }
        .status {
            background: rgba(255,255,255,0.2);
            padding: 1.5rem;
            border-radius: 12px;
            margin: 2rem 0;
            border: 1px solid rgba(255,255,255,0.2);
        }
        .loading {
            display: inline-block;
            width: 24px;
            height: 24px;
            border: 3px solid rgba(255,255,255,0.3);
            border-radius: 50%;
            border-top-color: white;
            animation: spin 1s ease-in-out infinite;
            margin-right: 0.8rem;
            vertical-align: middle;
        }
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        .features {
            text-align: left;
            margin: 2rem 0;
            background: rgba(255,255,255,0.1);
            padding: 2rem;
            border-radius: 12px;
            border: 1px solid rgba(255,255,255,0.2);
        }
        .features h3 {
            margin-bottom: 1.5rem;
            text-align: center;
            font-size: 1.5rem;
            color: #fff;
        }
        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            list-style: none;
        }
        .features li {
            padding: 0.8rem;
            background: rgba(255,255,255,0.1);
            border-radius: 8px;
            display: flex;
            align-items: center;
        }
        .features li::before {
            content: "🎵";
            margin-right: 0.8rem;
            font-size: 1.2rem;
        }
        .buttons {
            margin-top: 2rem;
        }
        .btn {
            background: rgba(255,255,255,0.2);
            border: 2px solid rgba(255,255,255,0.3);
            color: white;
            padding: 1rem 2rem;
            border-radius: 30px;
            cursor: pointer;
            margin: 0.5rem;
            text-decoration: none;
            display: inline-block;
            font-weight: 500;
            transition: all 0.3s ease;
        }
        .btn:hover {
            background: rgba(255,255,255,0.3);
            transform: translateY(-2px);
            box-shadow: 0 4px 20px rgba(0,0,0,0.2);
        }
        .btn.primary {
            background: rgba(102, 126, 234, 0.8);
            border-color: rgba(102, 126, 234, 1);
        }
        .btn.primary:hover {
            background: rgba(102, 126, 234, 1);
        }
        .info {
            margin-top: 2rem;
            padding: 1rem;
            background: rgba(255,255,255,0.05);
            border-radius: 8px;
            font-size: 0.9rem;
            opacity: 0.8;
            line-height: 1.5;
        }
        @media (max-width: 768px) {
            .title { font-size: 2.5rem; }
            .logo { font-size: 4rem; }
            .container { margin: 1rem; padding: 1.5rem; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">🎵</div>
        <h1 class="title">YesPlayMusic</h1>
        <p class="subtitle">高颜值的第三方网易云播放器<br>现已在 Home Assistant 中运行</p>
        
        <div class="status" id="status">
            <div class="loading"></div>
            <span id="status-text">正在启动音乐服务...</span>
        </div>
        
        <div class="features">
            <h3>🎶 功能特色</h3>
            <ul class="features-grid">
                <li>网易云账号登录</li>
                <li>支持 MV 播放</li>
                <li>实时歌词显示</li>
                <li>私人 FM 电台</li>
                <li>每日推荐歌曲</li>
                <li>音乐云盘支持</li>
                <li>深色/浅色主题</li>
                <li>无社交功能</li>
                <li>支持海外访问</li>
                <li>PWA 应用支持</li>
                <li>快捷键操作</li>
                <li>高品质音乐</li>
            </ul>
        </div>
        
        <div class="buttons">
            <a href="#" onclick="checkAndStart()" class="btn primary" id="start-btn">
                🚀 启动 YesPlayMusic
            </a>
            <a href="/api/ping" target="_blank" class="btn">🔗 测试API连接</a>
            <a href="#" onclick="location.reload()" class="btn">🔄 刷新页面</a>
        </div>
        
        <div class="info">
            <p><strong>使用说明：</strong></p>
            <p>1. 点击"启动 YesPlayMusic"开始使用</p>
            <p>2. 建议登录网易云账号获得完整功能</p>
            <p>3. 支持扫码登录、手机号登录、邮箱登录</p>
            <p>4. 如遇问题可尝试刷新页面</p>
        </div>
    </div>

    <script>
        let checkCount = 0;
        const maxChecks = 20;
        
        function updateStatus(text, isLoading = true) {
            const statusText = document.getElementById('status-text');
            const loading = document.querySelector('.loading');
            statusText.textContent = text;
            loading.style.display = isLoading ? 'inline-block' : 'none';
        }
        
        function checkAndStart() {
            checkCount++;
            updateStatus('正在检查服务状态...', true);
            
            // 尝试构建并启动应用
            fetch('/build-app', { method: 'POST' })
                .then(response => {
                    if (response.ok) {
                        updateStatus('应用构建成功，正在启动...', true);
                        setTimeout(() => {
                            window.location.href = '/app';
                        }, 3000);
                        return;
                    }
                    throw new Error('Build failed');
                })
                .catch(() => {
                    // 如果构建失败，直接跳转到外部版本
                    updateStatus('正在跳转到在线版本...', true);
                    setTimeout(() => {
                        window.open('https://music.qier222.com', '_blank');
                        updateStatus('已在新标签页打开在线版本', false);
                    }, 2000);
                });
        }
        
        // 页面加载完成后自动检查
        window.addEventListener('load', function() {
            setTimeout(() => {
                updateStatus('YesPlayMusic 已准备就绪', false);
            }, 2000);
        });
        
        // API连接测试
        function testAPI() {
            fetch('/api/ping')
                .then(response => {
                    if (response.ok) {
                        updateStatus('API连接正常 ✅', false);
                    } else {
                        updateStatus('API连接异常，但不影响基本使用', false);
                    }
                })
                .catch(() => {
                    updateStatus('API连接失败，将使用备用方案', false);
                });
        }
        
        // 3秒后测试API
        setTimeout(testAPI, 3000);
    </script>
</body>
</html>
EOF

# 复制配置文件
COPY rootfs /

# 尝试构建YesPlayMusic（可选，失败不影响启动）
RUN echo "Attempting to build YesPlayMusic..." && \
    (git clone --depth 1 https://github.com/qier222/YesPlayMusic.git /tmp/build && \
     cd /tmp/build && \
     echo 'VUE_APP_NETEASE_API_URL=/api' > .env && \
     yarn install --frozen-lockfile --network-timeout 60000 --ignore-engines && \
     yarn build && \
     cp -r dist/* /var/www/html/ && \
     echo "YesPlayMusic built successfully") || \
    echo "Build failed, will use fallback interface"

# 清理构建缓存
RUN rm -rf /tmp/build /root/.npm /root/.yarn-cache

# 设置权限
RUN chmod +x /usr/local/bin/run.sh /usr/local/bin/setup_nginx.sh && \
    chown -R nginx:nginx /var/www/html /var/log/nginx /var/lib/nginx /run/nginx

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# 暴露端口
EXPOSE 80

# 环境变量
ENV NETEASE_API_URL=https://music-api.hankqin.com
ENV SSL=false
ENV VUE_APP_NETEASE_API_URL=/api

# 标签
LABEL \
    io.hass.name="YesPlayMusic" \
    io.hass.description="高颜值的第三方网易云播放器" \
    io.hass.type="addon" \
    io.hass.version="1.0.5"

# 启动命令
CMD ["/usr/local/bin/run.sh"]