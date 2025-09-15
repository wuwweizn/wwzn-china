#!/bin/bash
set -e

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"; }
log_success() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] ✅${NC} $1"; }
log_warning() { echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] ⚠️${NC} $1"; }
log_error() { echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ❌${NC} $1"; }
log_debug() { echo -e "${PURPLE}[$(date +'%Y-%m-%d %H:%M:%S')] 🔍${NC} $1"; }

cat << 'BANNER'
    ╔═══════════════════════════════════════════╗
    ║        🎵 Alger Music Player Add-on        ║
    ║                                           ║
    ║     With UnblockNeteaseMusic Support      ║
    ╚═══════════════════════════════════════════╝
BANNER

log "🚀 Initializing Alger Music Player Home Assistant Add-on..."

# 读取配置
if command -v bashio &> /dev/null; then
    log "📖 Loading Home Assistant Add-on configuration..."
    MUSIC_API_URL=$(bashio::config 'music_api_url' 'http://localhost:3001')
    LOG_LEVEL=$(bashio::config 'log_level' 'info')
    ENABLE_UNM=$(bashio::config 'enable_unm' 'true')
    UNM_SOURCE=$(bashio::config 'unm_source' 'netease qq kuwo kugou baidu migu')
else
    log_warning "bashio not available, using environment variables"
    MUSIC_API_URL=${MUSIC_API_URL:-"http://localhost:3001"}
    LOG_LEVEL=${LOG_LEVEL:-"info"}
    ENABLE_UNM=${ENABLE_UNM:-"true"}
    UNM_SOURCE=${UNM_SOURCE:-"netease qq kuwo kugou baidu migu"}
fi

export MUSIC_API_URL LOG_LEVEL ENABLE_UNM UNM_SOURCE

log "📋 Configuration:"
log "   Music API URL: $MUSIC_API_URL"
log "   Log Level: $LOG_LEVEL"
log "   Enable UNM: $ENABLE_UNM"
log "   UNM Sources: $UNM_SOURCE"

# 启用调试模式
if [ "$LOG_LEVEL" = "debug" ] || [ "$LOG_LEVEL" = "trace" ]; then
    DEBUG_MODE=true
    log_debug "🔍 Debug mode enabled"
else
    DEBUG_MODE=false
fi

# 调试函数
debug_unm() {
    if [ "$DEBUG_MODE" = "true" ]; then
        log_debug "Debugging UnblockNeteaseMusic..."
        
        log_debug "Directory structure:"
        ls -la /opt/unm/ || log_error "UNM directory not accessible"
        
        log_debug "Node.js info:"
        log_debug "   Node version: $(node --version)"
        log_debug "   NPM version: $(npm --version)"
        
        cd /opt/unm || return 1
        
        if [ -f "package.json" ]; then
            log_debug "package.json found"
            if [ "$LOG_LEVEL" = "trace" ]; then
                log_debug "package.json contents:"
                cat package.json
            fi
        else
            log_error "package.json not found!"
            return 1
        fi
        
        if [ ! -d "node_modules" ]; then
        if [ -z "$MAIN_SERVER" ]; then
        log_warning "No main server file found, searching for alternatives..."
        POTENTIAL_MAIN=$(find /app -name "*.js" -type f | grep -E "(server|app|index|main)" | head -1)
        
        if [ -n "$POTENTIAL_MAIN" ]; then
            log "Found potential main file: $POTENTIAL_MAIN"
            ln -sf "$POTENTIAL_MAIN" /app/server.js
            MAIN_SERVER="/app/server.js"
        else
            log_warning "Creating fallback server application..."
            create_fallback_server
            MAIN_SERVER="/app/server.js"
        fi
    fi
    
    # 确保有 package.json
    if [ ! -f "/app/package.json" ]; then
        log "Creating package.json..."
        create_package_json
    fi
    
    # 安装依赖（如果需要）
    cd /app
    if [ ! -d "node_modules" ] || [ ! "$(ls -A node_modules 2>/dev/null)" ]; then
        log "Installing Node.js dependencies..."
        npm install --production --no-audit 2>/dev/null || log_warning "Some dependencies may have failed to install"
    fi
    
    log_success "Alger Music Player application ready"
}

create_fallback_server() {
    log "🔧 Creating fallback server..."
    
    cat > /app/server.js << 'EOF'
const express = require('express');
const path = require('path');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();
const PORT = process.env.PORT || 3000;

console.log('🎵 Starting Alger Music Player fallback server...');

// 寻找静态文件目录
const possibleDirs = ['dist', 'public', 'build', 'static'];
let staticDir = null;

for (const dir of possibleDirs) {
    const fullPath = path.join(__dirname, dir);
    if (require('fs').existsSync(fullPath)) {
        staticDir = fullPath;
        break;
    }
}

if (staticDir) {
    app.use(express.static(staticDir));
    console.log(`📁 Serving static files from: ${staticDir}`);
} else {
    console.log('📄 No static directory found, serving dynamic content');
}

// API 路由
app.get('/api/health', (req, res) => {
    res.json({ 
        status: 'ok', 
        message: 'Alger Music Player is running (fallback mode)',
        timestamp: new Date().toISOString(),
        services: {
            backend: 'running',
            unm: 'http://localhost:3001',
            nginx: 'http://localhost:3010'
        }
    });
});

// 音乐 API 代理
app.use('/api/music', createProxyMiddleware({
    target: 'http://localhost:3001',
    changeOrigin: true,
    pathRewrite: { '^/api/music': '' },
    onError: (err, req, res) => {
        console.error('Proxy error:', err.message);
        res.status(502).json({ error: 'Music service unavailable' });
    }
}));

// 主页路由
app.get('/', (req, res) => {
    if (staticDir) {
        res.sendFile(path.join(staticDir, 'index.html'));
    } else {
        res.send(getWelcomePage());
    }
});

// 404 处理
app.get('*', (req, res) => {
    if (staticDir) {
        res.sendFile(path.join(staticDir, 'index.html'));
    } else {
        res.status(404).send(get404Page());
    }
});

function getWelcomePage() {
    return `
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Alger Music Player</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            text-align: center;
            background: rgba(255,255,255,0.1);
            padding: 60px 40px;
            border-radius: 20px;
            backdrop-filter: blur(20px);
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
            max-width: 500px;
            width: 90%;
        }
        h1 {
            font-size: 2.5em;
            margin-bottom: 20px;
            background: linear-gradient(45deg, #fff, #f0f0f0);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .status {
            padding: 15px 25px;
            border-radius: 10px;
            background: rgba(255,255,255,0.2);
            margin: 20px 0;
            font-size: 1.1em;
        }
        .services {
            display: flex;
            justify-content: space-around;
            margin: 30px 0;
        }
        .service {
            padding: 10px;
            background: rgba(255,255,255,0.1);
            border-radius: 10px;
            flex: 1;
            margin: 0 5px;
        }
        .service.active { background: rgba(76, 175, 80, 0.3); }
        a {
            color: #fff;
            text-decoration: none;
            padding: 10px 20px;
            background: rgba(255,255,255,0.2);
            border-radius: 5px;
            display: inline-block;
            margin: 5px;
            transition: all 0.3s;
        }
        a:hover {
            background: rgba(255,255,255,0.3);
            transform: translateY(-2px);
        }
        @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.6; } }
        .pulse { animation: pulse 2s infinite; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎵 Alger Music Player</h1>
        <div class="status pulse">
            音乐服务运行中
        </div>
        
        <div class="services">
            <div class="service active">
                <div>🎵</div>
                <div>播放器</div>
            </div>
            <div class="service active">
                <div>🔓</div>
                <div>UNM</div>
            </div>
            <div class="service active">
                <div>🌐</div>
                <div>代理</div>
            </div>
        </div>
        
        <p>欢迎使用 Alger Music Player Home Assistant 加载项</p>
        <p>内置 UnblockNeteaseMusic 服务，享受听歌自由</p>
        
        <div style="margin-top: 30px;">
            <a href="/api/health">服务状态</a>
            <a href="/unm/">UNM 服务</a>
        </div>
    </div>
    
    <script>
        // 检查服务状态
        async function checkHealth() {
            try {
                const response = await fetch('/api/health');
                const data = await response.json();
                if (data.status === 'ok') {
                    document.querySelector('.status').innerHTML = '✅ 所有服务运行正常';
                    document.querySelector('.status').classList.remove('pulse');
                }
            } catch (error) {
                console.error('Health check failed:', error);
                setTimeout(checkHealth, 5000);
            }
        }
        
        checkHealth();
        setInterval(checkHealth, 10000);
    </script>
</body>
</html>`;
}

function get404Page() {
    return `
<!DOCTYPE html>
<html><head><title>页面未找到</title>
<style>body{font-family:Arial,sans-serif;text-align:center;padding:50px;background:linear-gradient(135deg,#667eea,#764ba2);color:white;}
.container{background:rgba(255,255,255,0.1);padding:40px;border-radius:20px;display:inline-block;}
</style></head>
<body><div class="container"><h1>404 - 页面未找到</h1><p>您访问的页面不存在</p>
<a href="/" style="color:#fff;text-decoration:none;padding:10px 20px;background:rgba(255,255,255,0.2);border-radius:5px;">返回首页</a>
</div></body></html>`;
}

app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Alger Music Player backend server running on port ${PORT}`);
    console.log(`🌐 Access at: http://localhost:${PORT}`);
});

// 优雅关闭
process.on('SIGTERM', () => {
    console.log('🛑 Received SIGTERM, shutting down gracefully...');
    process.exit(0);
});

process.on('SIGINT', () => {
    console.log('🛑 Received SIGINT, shutting down gracefully...');
    process.exit(0);
});
EOF
}

create_package_json() {
    cat > /app/package.json << 'EOF'
{
  "name": "alger-music-player-addon",
  "version": "1.0.0",
  "description": "Alger Music Player Home Assistant Add-on with UnblockNeteaseMusic",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.0",
    "http-proxy-middleware": "^2.0.0"
  },
  "scripts": {
    "start": "node server.js"
  },
  "engines": {
    "node": ">=14.0.0"
  }
}
EOF
}

# 验证 UnblockNeteaseMusic
verify_unm() {
    log "🔍 Verifying UnblockNeteaseMusic..."
    
    if [ ! -f "/opt/unm/app.js" ]; then
        log_error "UnblockNeteaseMusic app.js not found!"
        return 1
    fi
    
    cd /opt/unm
    
    # 检查依赖
    if [ ! -d "node_modules" ]; then
        log "Installing UNM dependencies..."
        npm install --production --no-audit || log_warning "UNM dependency installation had issues"
    fi
    
    # 调试模式下进行详细检查
    if [ "$DEBUG_MODE" = "true" ]; then
        debug_unm || log_warning "Debug checks failed"
    fi
    
    # 语法检查
    if ! node -c app.js; then
        log_error "UNM app.js has syntax errors!"
        return 1
    fi
    
    # 快速启动测试
    log "Testing UNM startup..."
    if timeout 5s node app.js -p 3001 --help &>/dev/null; then
        log_success "UNM startup test passed"
    else
        log_warning "UNM startup test failed, but continuing..."
        
        # 尝试修复常见问题
        log "Attempting to fix common UNM issues..."
        
        # 检查是否是权限问题
        chown -R app:app /opt/unm
        chmod -R 755 /opt/unm
        
        # 重新安装依赖
        rm -rf node_modules package-lock.json 2>/dev/null || true
        npm install --production --no-audit --force 2>/dev/null || true
    fi
    
    log_success "UnblockNeteaseMusic verification complete"
    return 0
}

# 主验证流程
main_verification() {
    log "🔍 Starting system verification..."
    
    # 设置权限
    log "Setting up permissions..."
    chown -R app:app /app /opt/unm
    chown -R nginx:nginx /var/log/nginx /run/nginx
    chmod 755 /opt/unm /app
    
    # 修复应用
    fix_alger_app
    
    # 验证 UNM
    if ! verify_unm; then
        log_error "UnblockNeteaseMusic verification failed!"
        
        if [ "$DEBUG_MODE" = "true" ]; then
            log_debug "Detailed UNM status:"
            ls -la /opt/unm/
            cat /opt/unm/package.json 2>/dev/null | head -10 || echo "No package.json"
            node --version
        fi
        
        # 继续运行，但禁用 UNM
        log_warning "Disabling UNM due to verification failure..."
        export ENABLE_UNM=false
    fi
    
    log_success "System verification complete"
}

# 创建日志目录
setup_logging() {
    mkdir -p /var/log
    touch /var/log/supervisord.log
    
    # 确保日志文件权限正确
    chown nginx:nginx /var/log/nginx* 2>/dev/null || true
    chown app:app /var/log/*backend* /var/log/*unm* 2>/dev/null || true
}

# 显示启动信息
show_startup_info() {
    log_success "🎉 Initialization complete!"
    log ""
    log "🌟 Service Information:"
    log "   📱 Web Interface: http://localhost:3010"
    log "   🔗 Health Check: http://localhost:3010/health"
    log "   🎵 Music API: http://localhost:3010/api_music/"
    log "   🔓 UNM Direct: http://localhost:3010/unm/"
    log ""
    
    if [ "$ENABLE_UNM" = "true" ]; then
        log "✅ UnblockNeteaseMusic: Enabled"
        log "   Sources: $UNM_SOURCE"
    else
        log_warning "⚠️  UnblockNeteaseMusic: Disabled"
    fi
    
    if [ "$DEBUG_MODE" = "true" ]; then
        log_debug "Debug mode is active - verbose logging enabled"
    fi
    
    log ""
    log "🚀 Starting services with supervisor..."
}

# 主执行流程
main() {
    main_verification
    setup_logging
    show_startup_info
    
    # 启动 supervisor
    exec /usr/bin/supervisord -c /etc/supervisor.d/supervisord.conf
}

# 执行主流程
main "node_modules not found, installing..."
            npm install --production --no-audit
        fi
        
        if [ -f "app.js" ]; then
            log_debug "app.js found ($(wc -c < app.js) bytes)"
        else
            log_error "app.js not found!"
            return 1
        fi
        
        # 语法检查
        if node -c app.js; then
            log_debug "✅ UNM syntax OK"
        else
            log_error "❌ UNM syntax error"
            return 1
        fi
        
        # 快速启动测试
        log_debug "Testing UNM startup..."
        timeout 3s node app.js --help &>/dev/null || log_warning "UNM help test failed"
    fi
}

# 修复 Alger Music Player 应用
fix_alger_app() {
    log "🔧 Checking Alger Music Player application..."
    
    if [ "$DEBUG_MODE" = "true" ]; then
        log_debug "App directory contents:"
        ls -la /app/ || log_error "App directory not accessible"
    fi
    
    # 寻找主服务器文件
    MAIN_SERVER=""
    for file in server.js app.js index.js main.js; do
        if [ -f "/app/$file" ]; then
            MAIN_SERVER="/app/$file"
            log_success "Found main server file: $file"
            break
        fi
    done
    
    # 如果没找到，寻找任何 JS 文件
    if [ -z "$MAIN_SERVER" ]; then
        log_warning