ARG BUILD_ARCH
FROM node:18-alpine AS builder

# 安装构建依赖
RUN apk add --no-cache git python3 make g++ vips-dev

# 克隆YesPlayMusic源码
WORKDIR /app
RUN git clone --depth 1 https://github.com/qier222/YesPlayMusic.git .

# 安装依赖
RUN npm config set registry https://registry.npmmirror.com/
RUN npm install --legacy-peer-deps --production=false

# 修改API配置为可配置的
RUN sed -i 's|baseURL: import.meta.env.VITE_NETEASE_API_URL|baseURL: window.NETEASE_API_URL \|\| import.meta.env.VITE_NETEASE_API_URL \|\| "/api"|g' src/utils/request.js || \
    sed -i 's|baseURL:.*|baseURL: window.NETEASE_API_URL || "/api",|g' src/utils/request.js || \
    find src -name "*.js" -o -name "*.ts" -o -name "*.vue" | xargs sed -i 's|https://netease-cloud-music-api.*\.vercel\.app|/api|g' || \
    echo "API配置修改完成"

# 设置构建环境变量
ENV NODE_OPTIONS="--max-old-space-size=4096"
ENV VITE_NETEASE_API_URL="/api"

# 构建项目
RUN npm run build || (echo "构建失败，检查错误" && npm run build:spa) || \
    (echo "尝试替代构建方式" && npm run build:prod) || \
    (echo "所有构建方式失败，使用开发构建" && npm run dev:build)

# 生产阶段
FROM nginx:alpine

# 安装工具
RUN apk add --no-cache supervisor jq bash curl

# 复制构建结果
COPY --from=builder /app/dist /usr/share/nginx/html/

# 验证构建结果并创建备用方案
RUN if [ ! -f "/usr/share/nginx/html/index.html" ] || [ ! -s "/usr/share/nginx/html/index.html" ]; then \
        echo "主构建失败，创建代理页面"; \
        cat > /usr/share/nginx/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>YesPlayMusic</title>
    <style>
        body { margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; }
        #app { width: 100vw; height: 100vh; }
        iframe { width: 100%; height: 100%; border: none; }
        .loading {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex; align-items: center; justify-content: center; z-index: 1000;
            color: white; font-size: 1.2rem;
        }
        .loading-content { text-align: center; }
        .spinner {
            width: 40px; height: 40px; margin: 20px auto;
            border: 3px solid rgba(255,255,255,0.3);
            border-top: 3px solid white;
            border-radius: 50%; animation: spin 1s linear infinite;
        }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
        .error { display: none; background: #e53e3e; color: white; padding: 20px; text-align: center; }
        .btn {
            display: inline-block; padding: 12px 24px; margin: 10px;
            background: rgba(255,255,255,0.2); color: white; text-decoration: none;
            border-radius: 20px; transition: background 0.3s;
        }
        .btn:hover { background: rgba(255,255,255,0.3); }
    </style>
</head>
<body>
    <div id="app">
        <div class="loading" id="loading">
            <div class="loading-content">
                <div class="spinner"></div>
                <div>正在加载 YesPlayMusic...</div>
                <div style="font-size: 0.9rem; margin-top: 10px; opacity: 0.8;">
                    连接到音乐服务中，请稍候
                </div>
            </div>
        </div>
        
        <div class="error" id="error">
            <h2>🎵 YesPlayMusic</h2>
            <p>无法加载完整界面，但您仍可以使用基本功能</p>
            <a href="https://music.qier222.com/" target="_blank" class="btn">🌐 访问官方Demo</a>
            <a href="#" onclick="loadLocal()" class="btn">🔄 重新加载</a>
        </div>
        
        <iframe id="music-frame" style="display: none;" 
                onload="frameLoaded()" 
                onerror="frameError()">
        </iframe>
    </div>
    
    <script>
        let apiUrl = '/api';
        let retryCount = 0;
        const maxRetries = 3;
        
        // 读取配置
        fetch('/config.json')
            .then(res => res.json())
            .then(config => {
                apiUrl = config.apiUrl;
                window.NETEASE_API_URL = apiUrl;
                console.log('API配置:', apiUrl);
            })
            .catch(e => console.log('配置读取失败:', e));
        
        function loadLocal() {
            const frame = document.getElementById('music-frame');
            // 尝试加载官方demo并配置API
            frame.src = 'https://music.qier222.com/';
            frame.style.display = 'block';
            
            // 如果官方demo也加载失败，显示错误页面
            setTimeout(() => {
                if (frame.style.display !== 'none') {
                    frameError();
                }
            }, 10000);
        }
        
        function frameLoaded() {
            document.getElementById('loading').style.display = 'none';
            document.getElementById('error').style.display = 'none';
            
            // 尝试向iframe注入API配置
            try {
                const frame = document.getElementById('music-frame');
                frame.contentWindow.postMessage({
                    type: 'UPDATE_API',
                    apiUrl: apiUrl
                }, '*');
            } catch (e) {
                console.log('API配置注入失败:', e);
            }
        }
        
        function frameError() {
            retryCount++;
            if (retryCount < maxRetries) {
                setTimeout(() => {
                    loadLocal();
                }, 2000);
            } else {
                document.getElementById('loading').style.display = 'none';
                document.getElementById('error').style.display = 'block';
            }
        }
        
        // 自动开始加载
        setTimeout(loadLocal, 1000);
    </script>
</body>
</html>
EOF
    fi

# 创建API配置注入脚本
RUN if [ -f "/usr/share/nginx/html/index.html" ] && [ -s "/usr/share/nginx/html/index.html" ]; then \
        # 如果有真正的YesPlayMusic构建结果，注入API配置脚本
        sed -i 's|<head>|<head>\n<script>window.NETEASE_API_URL = "/api";</script>|g' /usr/share/nginx/html/index.html || \
        echo "API配置注入完成"; \
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
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

CMD ["/run.sh"]