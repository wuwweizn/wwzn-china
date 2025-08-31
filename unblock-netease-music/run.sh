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

# 设置日志级别环境变量
case "${LOG_LEVEL}" in
    "debug")
        export DEBUG="app*"
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

# 检查网络连接
log_info "检查网络连接..."
if ! wget -q --spider --timeout=10 https://music.163.com/ 2>/dev/null; then
    log_warn "无法访问网易云音乐，请检查网络连接"
fi

# 启动服务
log_info "启动参数: ${ARGS[*]}"
log_info "UnblockNeteaseMusic 服务正在启动..."

cd /app

# 使用exec确保信号正确传递
exec node app.js "${ARGS[@]}"