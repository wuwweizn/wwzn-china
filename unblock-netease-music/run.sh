#!/usr/bin/env bashio

# 设置颜色输出
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 从配置中读取选项
PORT=$(bashio::config 'port')
HOST=$(bashio::config 'host')
SOURCE_ORDER=$(bashio::config 'source_order')
ENABLE_FLAC=$(bashio::config 'enable_flac')
ENABLE_LOCAL_VIP=$(bashio::config 'enable_local_vip')
SEARCH_LIMIT=$(bashio::config 'search_limit')
LOG_LEVEL=$(bashio::config 'log_level')
STRICT=$(bashio::config 'strict')
ENDPOINT=$(bashio::config 'endpoint')
PROXY_ONLY=$(bashio::config 'proxy_only_netease_music')

log_info "开始启动 UnblockNeteaseMusic 服务..."
log_info "监听地址: ${HOST}:${PORT}"
log_info "音源顺序: ${SOURCE_ORDER}"
log_info "日志级别: ${LOG_LEVEL}"

# 网络连接测试函数
test_network() {
    local url=$1
    local name=$2
    log_info "测试连接到 ${name}..."
    
    if curl -s --connect-timeout 10 --max-time 15 "${url}" > /dev/null 2>&1; then
        log_info "✅ ${name} 连接正常"
        return 0
    elif wget -q --timeout=10 --tries=2 --spider "${url}" 2>/dev/null; then
        log_info "✅ ${name} 连接正常 (via wget)"
        return 0
    else
        log_warn "⚠️ ${name} 连接失败，但服务将继续启动"
        return 1
    fi
}

# 检查各个音源的连接性
log_info "开始网络连接检查..."
test_network "https://music.163.com/" "网易云音乐"
test_network "https://www.kuwo.cn/" "酷我音乐"
test_network "https://www.kugou.com/" "酷狗音乐"
test_network "https://music.migu.cn/" "咪咕音乐"

# 构建启动命令参数
ARGS=()
ARGS+=("--port" "${PORT}")
ARGS+=("--host" "${HOST}")

if [ -n "${SOURCE_ORDER}" ]; then
    ARGS+=("--source" "${SOURCE_ORDER}")
fi

if [ "${ENABLE_FLAC}" = "true" ]; then
    ARGS+=("--enable-flac")
    log_info "已启用 FLAC 格式支持"
fi

if [ "${ENABLE_LOCAL_VIP}" = "true" ]; then
    ARGS+=("--enable-local-vip")
    log_info "已启用本地 VIP 模式"
fi

if [ -n "${SEARCH_LIMIT}" ] && [ "${SEARCH_LIMIT}" != "3" ]; then
    ARGS+=("--search-limit" "${SEARCH_LIMIT}")
fi

if [ "${STRICT}" = "true" ]; then
    ARGS+=("--strict")
    log_info "已启用严格模式"
fi

if [ -n "${ENDPOINT}" ]; then
    ARGS+=("--endpoint" "${ENDPOINT}")
    log_info "使用自定义端点: ${ENDPOINT}"
fi

if [ "${PROXY_ONLY}" = "true" ]; then
    ARGS+=("--proxy-only-netease-music")
    log_info "仅代理网易云音乐流量"
fi

# 设置日志和调试环境变量
export NODE_ENV="production"
export ENABLE_LOCAL_VIP=1

case "${LOG_LEVEL}" in
    "debug")
        export DEBUG="app*"
        log_info "启用调试模式"
        ;;
    "info")
        export LOG_LEVEL="info"
        ;;
    "warn")
        export LOG_LEVEL="warn"
        ;;
    "error")
        export LOG_LEVEL="error"
        ;;
esac

# 检查必要文件
if [ ! -f "/app/app.js" ]; then
    log_error "❌ app.js 文件不存在！"
    exit 1
fi

if [ ! -f "/app/package.json" ]; then
    log_error "❌ package.json 文件不存在！"
    exit 1
fi

# 显示应用信息
log_info "应用信息："
if [ -f "/app/package.json" ]; then
    APP_VERSION=$(grep '"version"' /app/package.json | cut -d'"' -f4 2>/dev/null || echo "unknown")
    log_info "  版本: ${APP_VERSION}"
fi
log_info "  工作目录: $(pwd)"
log_info "  Node.js 版本: $(node --version)"

# 创建错误处理函数
handle_error() {
    log_error "❌ 应用异常退出，退出码: $?"
    log_error "请检查网络连接和配置设置"
    exit 1
}

# 设置错误处理
trap handle_error ERR

# 启动服务
log_info "启动参数: ${ARGS[*]}"
log_info "UnblockNeteaseMusic 服务正在启动..."
log_info "服务地址将是: http://${HOST}:${PORT}"

cd /app

# 使用exec确保信号正确传递，同时添加错误处理
exec node app.js "${ARGS[@]}" 2>&1 | while read -r line; do
    case "$line" in
        *"ERROR"*|*"error"*|*"Error"*)
            echo -e "${RED}[ERROR]${NC} $line"
            ;;
        *"WARN"*|*"warn"*|*"Warn"*)
            echo -e "${YELLOW}[WARN]${NC} $line"
            ;;
        *"listening"*|*"server"*|*"started"*)
            echo -e "${GREEN}[INFO]${NC} $line"
            ;;
        *)
            echo "$line"
            ;;
    esac
done