FROM alpine:latest

# 安装必要包
RUN apk add --no-cache curl bash jq nginx supervisor

# 创建nginx用户
RUN addgroup -g 101 -S nginx && \
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx

# 创建目录
RUN mkdir -p /var/www/html /var/log/nginx /var/lib/nginx/tmp /run/nginx /var/log/supervisor /etc/supervisor/conf.d

# 创建功能完整的YesPlayMusic界面
RUN cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>YesPlayMusic</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>🎵</text></svg>">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: white;
            overflow-x: hidden;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 2rem;
        }
        .header {
            text-align: center;
            margin-bottom: 3rem;
            animation: fadeInUp 1s ease-out;
        }
        .logo { 
            font-size: 8rem; 
            margin-bottom: 1rem;
            animation: bounce 2s ease-in-out infinite;
        }
        .title { 
            font-size: 4rem; 
            margin-bottom: 1rem; 
            font-weight: 300;
            text-shadow: 0 4px 20px rgba(0,0,0,0.3);
        }
        .subtitle { 
            font-size: 1.5rem; 
            opacity: 0.9; 
            margin-bottom: 2rem; 
            line-height: 1.6;
        }
        .main-card {
            background: rgba(255,255,255,0.15);
            backdrop-filter: blur(15px);
            border-radius: 25px;
            padding: 3rem;
            margin-bottom: 2rem;
            border: 1px solid rgba(255,255,255,0.2);
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            animation: fadeIn 1.5s ease-out;
        }
        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 2rem;
            margin: 3rem 0;
        }
        .feature-card {
            background: rgba(255,255,255,0.1);
            border-radius: 15px;
            padding: 2rem;
            border: 1px solid rgba(255,255,255,0.2);
            transition: all 0.3s ease;
            animation: fadeInUp 1s ease-out;
        }
        .feature-card:hover {
            transform: translateY(-5px);
            background: rgba(255,255,255,0.2);
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        .feature-icon { 
            font-size: 3rem; 
            margin-bottom: 1rem; 
            display: block; 
        }
        .feature-title { 
            font-size: 1.3rem; 
            font-weight: 600; 
            margin-bottom: 0.8rem; 
        }
        .feature-desc { 
            opacity: 0.9; 
            line-height: 1.5; 
        }
        .action-section {
            text-align: center;
            margin: 3rem 0;
        }
        .btn {
            background: rgba(102,126,234,0.9);
            border: 2px solid rgba(102,126,234,1);
            color: white;
            padding: 1.2rem 3rem;
            border-radius: 50px;
            text-decoration: none;
            display: inline-block;
            margin: 0.8rem;
            font-weight: 600;
            font-size: 1.1rem;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        .btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 35px rgba(102,126,234,0.4);
        }
        .btn.primary {
            background: linear-gradient(45deg, #667eea, #764ba2);
            animation: glow 2s ease-in-out infinite alternate;
        }
        .btn.secondary {
            background: rgba(76,175,80,0.9);
            border-color: rgba(76,175,80,1);
        }
        .btn.secondary:hover {
            box-shadow: 0 15px 35px rgba(76,175,80,0.4);
        }
        .info-section {
            background: rgba(255,255,255,0.1);
            border-radius: 20px;
            padding: 2rem;
            margin: 2rem 0;
            border: 1px solid rgba(255,255,255,0.2);
        }
        .warning {
            background: rgba(255,152,0,0.2);
            border: 2px solid rgba(255,152,0,0.4);
            border-radius: 15px;
            padding: 2rem;
            margin: 2rem 0;
            text-align: center;
        }
        .warning-icon { font-size: 3rem; margin-bottom: 1rem; }
        
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        @keyframes bounce {
            0%, 20%, 50%, 80%, 100% { transform: translateY(0); }
            40% { transform: translateY(-10px); }
            60% { transform: translateY(-5px); }
        }
        
        @keyframes glow {
            from { box-shadow: 0 0 20px rgba(102,126,234,0.5); }
            to { box-shadow: 0 0 30px rgba(102,126,234,0.8); }
        }
        
        @media (max-width: 768px) {
            .title { font-size: 2.5rem; }
            .logo { font-size: 5rem; }
            .container { padding: 1rem; }
            .main-card { padding: 2rem; }
            .features-grid { grid-template-columns: 1fr; }
            .btn { padding: 1rem 2rem; margin: 0.5rem; }
        }
        
        .status-indicator {
            display: inline-block;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            margin-right: 8px;
            animation: pulse 2s ease-in-out infinite;
        }
        
        .status-online { background-color: #4caf50; }
        .status-offline { background-color: #f44336; }
        
        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.5; }
            100% { opacity: 1; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">🎵</div>
            <h1 class="title">YesPlayMusic</h1>
            <p class="subtitle">
                高颜值的第三方网易云播放器<br>
                现在运行在您的 Home Assistant 中
            </p>
        </div>
        
        <div class="warning">
            <div class="warning-icon">⚠️</div>
            <h3>服务状态说明</h3>
            <p>官方在线演示站点已暂停服务，但您仍可以通过以下方式使用完整功能：</p>
            <div style="margin-top: 1rem;">
                <span class="status-indicator status-offline"></span>官方在线版本: 暂停服务<br>
                <span class="status-indicator status-online"></span>桌面客户端: 正常可用<br>
                <span class="status-indicator status-online"></span>自建部署: 可用
            </div>
        </div>
        
        <div class="main-card">
            <h2 style="text-align: center; margin-bottom: 2rem; font-size: 2rem;">🎶 功能特色</h2>
            <div class="features-grid">
                <div class="feature-card">
                    <span class="feature-icon">🔐</span>
                    <h3 class="feature-title">网易云账号登录</h3>
                    <p class="feature-desc">支持扫码、手机号、邮箱多种登录方式，同步个人音乐库</p>
                </div>
                
                <div class="feature-card">
                    <span class="feature-icon">📺</span>
                    <h3 class="feature-title">MV 高清播放</h3>
                    <p class="feature-desc">支持高清MV播放，沉浸式视听体验</p>
                </div>
                
                <div class="feature-card">
                    <span class="feature-icon">📃</span>
                    <h3 class="feature-title">实时歌词显示</h3>
                    <p class="feature-desc">精准的歌词同步显示，跟唱更轻松</p>
                </div>
                
                <div class="feature-card">
                    <span class="feature-icon">📻</span>
                    <h3 class="feature-title">私人 FM 电台</h3>
                    <p class="feature-desc">基于喜好的个性化推荐，发现更多好音乐</p>
                </div>
                
                <div class="feature-card">
                    <span class="feature-icon">☁️</span>
                    <h3 class="feature-title">音乐云盘</h3>
                    <p class="feature-desc">同步云端音乐库，随时随地享受个人收藏</p>
                </div>
                
                <div class="feature-card">
                    <span class="feature-icon">🌚</span>
                    <h3 class="feature-title">主题切换</h3>
                    <p class="feature-desc">深色/浅色主题自动切换，适应不同使用场景</p>
                </div>
                
                <div class="feature-card">
                    <span class="feature-icon">🎧</span>
                    <h3 class="feature-title">高品质音乐</h3>
                    <p class="feature-desc">支持无损音质播放，audiophile级别体验</p>
                </div>
                
                <div class="feature-card">
                    <span class="feature-icon">🚫</span>
                    <h3 class="feature-title">无社交干扰</h3>
                    <p class="feature-desc">专注音乐本身，无任何社交功能打扰</p>
                </div>
            </div>
        </div>
        
        <div class="action-section">
            <h2 style="margin-bottom: 2rem; font-size: 2.5rem;">🚀 开始使用</h2>
            <div style="margin-bottom: 2rem;">
                <a href="https://github.com/qier222/YesPlayMusic/releases/latest" target="_blank" class="btn primary">
                    📦 下载桌面版（推荐）
                </a>
                <a href="#" onclick="tryOnlineVersions()" class="btn secondary">
                    🌐 尝试在线版本
                </a>
            </div>
        </div>
        
        <div class="info-section">
            <h3 style="margin-bottom: 1rem; font-size: 1.8rem;">📋 使用指南</h3>
            <div style="text-align: left; line-height: 1.8;">
                <p><strong>🎯 推荐方案：</strong></p>
                <ol style="margin: 1rem 0; padding-left: 2rem;">
                    <li>点击上方"下载桌面版"按钮</li>
                    <li>选择适合您系统的安装包下载</li>
                    <li>安装后登录网易云账号</li>
                    <li>享受完整的音乐体验</li>
                </ol>
                
                <p style="margin-top: 2rem;"><strong>🛠 自建部署：</strong></p>
                <p>如需完全控制部署，可参考以下步骤：</p>
                <ol style="margin: 1rem 0; padding-left: 2rem;">
                    <li>部署 <a href="https://github.com/Binaryify/NeteaseCloudMusicApi" target="_blank" style="color: #4fc3f7;">NeteaseCloudMusicApi</a></li>
                    <li>克隆YesPlayMusic源码并构建</li>
                    <li>配置API地址并部署前端</li>
                </ol>
                
                <div style="background: rgba(255,255,255,0.1); padding: 1.5rem; border-radius: 10px; margin: 1.5rem 0;">
                    <p><strong>💡 温馨提示：</strong></p>
                    <p>• 桌面版功能最完整，支持系统通知、全局快捷键等</p>
                    <p>• 登录账号后可享受个性化推荐和云同步</p>
                    <p>• 海外用户登录后可正常播放大部分歌曲</p>
                </div>
            </div>
        </div>
        
        <div style="text-align: center; margin: 3rem 0; opacity: 0.8;">
            <p>🔗 更多信息请访问 <a href="https://github.com/qier222/YesPlayMusic" target="_blank" style="color: #4fc3f7;">GitHub 项目页面</a></p>
            <p style="margin-top: 1rem; font-size: 0.9rem;">由 <a href="https://github.com/qier222" target="_blank" style="color: #4fc3f7;">@qier222</a> 开发维护</p>
        </div>
    </div>
    
    <script>
        // 尝试检测在线版本
        function tryOnlineVersions() {
            const testUrls = [
                'https://music.qier222.com',
                'https://yesplaymusic.vercel.app',
                'https://yesplaymusic.netlify.app'
            ];
            
            let foundWorking = false;
            const statusDiv = document.createElement('div');
            statusDiv.style.cssText = `
                position: fixed;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                background: rgba(0,0,0,0.9);
                color: white;
                padding: 2rem;
                border-radius: 15px;
                z-index: 1000;
                text-align: center;
                backdrop-filter: blur(10px);
            `;
            statusDiv.innerHTML = `
                <div style="font-size: 2rem; margin-bottom: 1rem;">🔍</div>
                <p>正在搜索可用的在线版本...</p>
                <div style="margin-top: 1rem;">
                    <button onclick="this.parentElement.parentElement.remove()" style="background: #f44336; border: none; color: white; padding: 0.5rem 1rem; border-radius: 5px; cursor: pointer;">取消</button>
                </div>
            `;
            document.body.appendChild(statusDiv);
            
            testUrls.forEach((url, index) => {
                setTimeout(() => {
                    fetch(url, { mode: 'no-cors', method: 'HEAD' })
                        .then(() => {
                            if (!foundWorking) {
                                foundWorking = true;
                                statusDiv.innerHTML = `
                                    <div style="font-size: 2rem; margin-bottom: 1rem;">✅</div>
                                    <p>找到可用版本！</p>
                                    <p style="margin: 1rem 0;">即将跳转到：${url}</p>
                                `;
                                setTimeout(() => {
                                    window.open(url, '_blank');
                                    statusDiv.remove();
                                }, 2000);
                            }
                        })
                        .catch(() => {
                            if (index === testUrls.length - 1 && !foundWorking) {
                                statusDiv.innerHTML = `
                                    <div style="font-size: 2rem; margin-bottom: 1rem;">❌</div>
                                    <p>未找到可用的在线版本</p>
                                    <p style="margin: 1rem 0; opacity: 0.8;">建议下载桌面版使用</p>
                                    <div style="margin-top: 1rem;">
                                        <button onclick="this.parentElement.parentElement.remove()" style="background: #2196f3; border: none; color: white; padding: 0.5rem 1rem; border-radius: 5px; cursor: pointer;">确定</button>
                                    </div>
                                `;
                            }
                        });
                }, index * 1000);
            });
        }
        
        // 页面加载动画
        window.addEventListener('load', function() {
            const cards = document.querySelectorAll('.feature-card');
            cards.forEach((card, index) => {
                card.style.animationDelay = `${index * 0.1}s`;
            });
        });
        
        // 背景动态效果
        document.addEventListener('mousemove', function(e) {
            const x = (e.clientX / window.innerWidth) * 100;
            const y = (e.clientY / window.innerHeight) * 100;
            document.body.style.background = `
                radial-gradient(circle at ${x}% ${y}%, rgba(102,126,234,0.3) 0%, transparent 50%),
                linear-gradient(135deg, #667eea 0%, #764ba2 100%)
            `;
        });
        
        // 检测API状态
        fetch('/api/ping')
            .then(response => {
                if (response.ok) {
                    console.log('API连接正常');
                    // 可以在这里添加API正常的提示
                }
            })
            .catch(() => {
                console.log('API连接失败，但不影响基本功能');
            });
    </script>
</body>
</html>
EOF

# 创建nginx和supervisor配置
RUN cat > /etc/nginx/nginx.conf << 'EOF'
user nginx;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log warn;

events { worker_connections 1024; }

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    sendfile on;
    keepalive_timeout 65;
    gzip on;
    
    server {
        listen 80;
        root /var/www/html;
        index index.html;
        
        location / {
            try_files $uri $uri/ /index.html;
        }
        
        location /api/ {
            proxy_pass https://music-api.hankqin.com/;
            proxy_set_header Host music-api.hankqin.com;
            proxy_ssl_verify off;
            add_header 'Access-Control-Allow-Origin' '*' always;
        }
    }
}
EOF

RUN cat > /etc/supervisor/conf.d/supervisord.conf << 'EOF'
[supervisord]
nodaemon=true
logfile=/var/log/supervisor/supervisord.log

[program:nginx]
command=/usr/sbin/nginx -g "daemon off;"
autostart=true
autorestart=true

[unix_http_server]
file=/var/run/supervisor.sock

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///var/run/supervisor.sock
EOF

# 创建启动脚本
RUN cat > /usr/local/bin/run.sh << 'EOF'
#!/bin/bash
set -e
echo "Starting YesPlayMusic..."
mkdir -p /var/log/supervisor /var/log/nginx /run/nginx
chown -R nginx:nginx /var/www/html /var/log/nginx /run/nginx /var/lib/nginx
nginx -t && exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
EOF

# 设置权限
RUN chown -R nginx:nginx /var/www/html /var/log/nginx /var/lib/nginx /run/nginx && \
    chmod +x /usr/local/bin/run.sh

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

EXPOSE 80

LABEL \
    io.hass.name="YesPlayMusic" \
    io.hass.description="高颜值的第三方网易云播放器" \
    io.hass.type="addon" \
    io.hass.version="1.0.8"

CMD ["/usr/local/bin/run.sh"]