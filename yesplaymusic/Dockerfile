ARG BUILD_ARCH

# 使用官方构建好的静态文件
FROM alpine/curl AS downloader

WORKDIR /download

# 下载最新的YesPlayMusic构建版本
RUN curl -L -o yesplaymusic.zip \
    "https://github.com/qier222/YesPlayMusic/releases/latest/download/YesPlayMusic-web.zip" || \
    curl -L -o yesplaymusic.zip \
    "https://github.com/qier222/YesPlayMusic/archive/refs/heads/main.zip"

# 如果下载的是源码，则进行本地构建
FROM node:18-alpine AS builder

WORKDIR /app

# 复制下载的文件
COPY --from=downloader /download/yesplaymusic.zip ./

# 检查是否是预构建版本还是源码
RUN if unzip -l yesplaymusic.zip | grep -q "dist/"; then \
        echo "预构建版本" && unzip yesplaymusic.zip; \
    else \
        echo "源码版本，开始构建" && \
        unzip yesplaymusic.zip && \
        cd YesPlayMusic-* && \
        apk add --no-cache python3 make g++ && \
        npm config set registry https://registry.npmmirror.com/ && \
        npm install --legacy-peer-deps && \
        NODE_OPTIONS="--max-old-space-size=4096" npm run build && \
        mv dist ../dist; \
    fi

# 生产阶段
FROM nginx:alpine

# 安装必要的工具
RUN apk add --no-cache supervisor jq gettext curl

# 复制构建好的文件
COPY --from=builder /app/dist /usr/share/nginx/html

# 如果没有dist目录，尝试从其他可能的位置复制
RUN if [ ! -d "/usr/share/nginx/html" ] || [ -z "$(ls -A /usr/share/nginx/html)" ]; then \
        echo "尝试从其他位置复制文件"; \
        COPY --from=builder /app/YesPlayMusic-*/dist /usr/share/nginx/html 2>/dev/null || \
        COPY --from=builder /app/build /usr/share/nginx/html 2>/dev/null || \
        echo "使用备用静态文件"; \
    fi

# 创建默认的index.html（备用方案）
RUN if [ ! -f "/usr/share/nginx/html/index.html" ]; then \
        mkdir -p /usr/share/nginx/html && \
        cat > /usr/share/nginx/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>YesPlayMusic</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .error { color: #e74c3c; }
        .info { color: #3498db; }
        .button { 
            display: inline-block; 
            padding: 10px 20px; 
            background: #3498db; 
            color: white; 
            text-decoration: none; 
            border-radius: 5px; 
            margin: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>YesPlayMusic 加载中...</h1>
        <p class="info">正在初始化YesPlayMusic服务，请稍候...</p>
        <p>如果长时间无法加载，请检查：</p>
        <ul>
            <li>网易云API服务是否正常运行</li>
            <li>网络连接是否正常</li>
            <li>加载项配置是否正确</li>
        </ul>
        <a href="javascript:location.reload()" class="button">刷新页面</a>
        <a href="/api/check" class="button">检查API</a>
    </div>
    <script>
        // 每5秒尝试刷新一次，直到加载成功
        setTimeout(() => {
            if (document.title === 'YesPlayMusic') {
                location.reload();
            }
        }, 5000);
    </script>
</body>
</html>
EOF
    fi

# 复制配置文件
COPY nginx.conf /etc/nginx/templates/default.conf.template
COPY run.sh /run.sh
COPY supervisord.conf /etc/supervisord.conf

# 设置权限
RUN chmod +x /run.sh

# 暴露端口
EXPOSE 80 443

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# 启动
CMD ["/run.sh"]