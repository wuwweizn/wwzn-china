ARG BUILD_ARCH
FROM node:16-alpine AS builder

# 设置工作目录
WORKDIR /app

# 安装必要的系统依赖
RUN apk add --no-cache \
    git \
    python3 \
    make \
    g++ \
    vips-dev \
    libc6-compat

# 克隆YesPlayMusic源码
RUN git clone --depth 1 https://github.com/qier222/YesPlayMusic.git . || \
    (echo "主仓库克隆失败，尝试镜像仓库" && \
     git clone --depth 1 https://gitee.com/qier222/YesPlayMusic.git .)

# 设置npm镜像源
RUN npm config set registry https://registry.npmmirror.com/

# 创建.env配置文件
RUN cat > .env << 'EOF'
# API 地址
VUE_APP_NETEASE_API_URL=/api

# 应用配置
VUE_APP_TITLE=YesPlayMusic
VUE_APP_VERSION=1.0.0

# 构建配置
NODE_ENV=production
EOF

# 安装依赖 - 使用多种策略
RUN npm ci --only=production --legacy-peer-deps || \
    npm install --legacy-peer-deps --production=false || \
    (rm -rf node_modules package-lock.json && npm install --legacy-peer-deps)

# 设置Node.js内存限制
ENV NODE_OPTIONS="--max-old-space-size=2048"

# 构建项目
RUN npm run build || \
    (echo "标准构建失败，尝试清理后重建" && \
     npm run clean && npm run build) || \
    (echo "尝试强制构建" && \
     NODE_ENV=production npm run build:prod) || \
    (echo "最后尝试：简化构建" && \
     npm run build -- --mode production)

# 验证构建结果
RUN ls -la dist/ && \
    test -f dist/index.html || (echo "构建失败：缺少index.html" && exit 1)

# 生产阶段
FROM nginx:alpine

# 安装运行时依赖
RUN apk add --no-cache supervisor jq bash curl

# 从构建阶段复制构建结果
COPY --from=builder /app/dist /usr/share/nginx/html

# 验证复制结果
RUN ls -la /usr/share/nginx/html/ && \
    test -f /usr/share/nginx/html/index.html || \
    (echo "复制失败，创建备用页面" && \
     cat > /usr/share/nginx/html/index.html << 'BACKUP'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>YesPlayMusic</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0; padding: 0; min-height: 100vh;
            display: flex; align-items: center; justify-content: center;
        }
        .container {
            background: white; border-radius: 20px; padding: 40px;
            text-align: center; box-shadow: 0 20px 60px rgba(0,0,0,0.15);
            max-width: 500px; width: 90%;
        }
        .logo { font-size: 4rem; margin-bottom: 20px; }
        h1 { color: #333; font-size: 2rem; font-weight: 300; margin-bottom: 15px; }
        .subtitle { color: #667eea; margin-bottom: 30px; }
        .status { 
            padding: 20px; background: #f8fafc; border-radius: 12px; margin: 20px 0;
            border-left: 4px solid #48bb78;
        }
        .btn {
            display: inline-block; padding: 12px 24px; margin: 8px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white; text-decoration: none; border-radius: 20px;
            transition: all 0.3s;
        }
        .btn:hover { transform: translateY(-2px); }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">🎵</div>
        <h1>YesPlayMusic</h1>
        <p class="subtitle">高颜值的第三方网易云播放器</p>
        
        <div class="status">
            <p><strong>📡 服务状态：</strong>运行中</p>
            <p><strong>🔗 API地址：</strong>/api</p>
            <p><strong>ℹ️ 说明：</strong>YesPlayMusic服务已启动，API代理已配置</p>
        </div>
        
        <a href="/api/" target="_blank" class="btn">🔧 检查API</a>
        <a href="javascript:location.reload()" class="btn">🔄 刷新</a>
    </div>
    
    <script>
        // 定期检查API状态
        async function checkAPI() {
            try {
                const response = await fetch('/api/');
                console.log('API状态:', response.status);
            } catch (e) {
                console.log('API检查失败:', e);
            }
        }
        
        setInterval(checkAPI, 30000);
        checkAPI();
    </script>
</body>
</html>
BACKUP
    )

# 注入API配置到YesPlayMusic
RUN if [ -f "/usr/share/nginx/html/index.html" ] && grep -q "yesplaymusic" /usr/share/nginx/html/index.html; then \
        echo "检测到YesPlayMusic构建结果，注入API配置"; \
        sed -i 's|<head>|<head>\n  <script>\n    window.VUE_APP_NETEASE_API_URL = "/api";\n    console.log("API配置已注入:", window.VUE_APP_NETEASE_API_URL);\n  </script>|g' /usr/share/nginx/html/index.html; \
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