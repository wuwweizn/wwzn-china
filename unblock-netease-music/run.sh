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
STRICT=$(bashio::config 'strict')
ENDPOINT=$(bashio::config 'endpoint')
LOG_LEVEL=$(bashio::config 'log_level')

log_info "=== UnblockNeteaseMusic 启动中 ==="
log_info "端口: ${PORT}"
log_info "地址: ${HOST}"
log_info "音源: ${SOURCE_ORDER}"
log_info "严格模式: ${STRICT}"
log_info "日志级别: ${LOG_LEVEL}"

# 检查必要文件
if [ ! -f "/app/app.js" ]; then
    log_error "❌ app.js 文件不存在！"
    exit 1
fi

# 设置环境变量
export NODE_ENV="production"
export ENABLE_LOCAL_VIP=1

# 设置调试级别
case "${LOG_LEVEL}" in
    "debug")
        export DEBUG="*"
        ;;
    "info"|"warn"|"error")
        export DEBUG=""
        ;;
esac

# 构建正确的参数 - 使用UnblockNeteaseMusic实际支持的参数格式
ARGS=()

# 添加端口参数
ARGS+=("-p")
ARGS+=("${PORT}")

# 添加地址参数 (注意：是 -a 不是 --host)
ARGS+=("-a")
ARGS+=("${HOST}")

# 添加音源参数
if [ -n "${SOURCE_ORDER}" ] && [ "${SOURCE_ORDER}" != "" ]; then
    ARGS+=("-o")
    # 将空格分隔的音源添加为单独的参数
    for source in ${SOURCE_ORDER}; do
        ARGS+=("${source}")
        log_info "添加音源: ${source}"
    done
fi

# 添加严格模式
if [ "${STRICT}" = "true" ]; then
    ARGS+=("-s")
    log_info "启用严格模式"
fi

# 添加自定义端点
if [ -n "${ENDPOINT}" ] && [ "${ENDPOINT}" != "" ]; then
    if [[ "${ENDPOINT}" =~ ^https?:// ]]; then
        ARGS+=("-e")
        ARGS+=("${ENDPOINT}")
        log_info "使用自定义端点: ${ENDPOINT}"
    else
        log_warn "端点格式无效: ${ENDPOINT}"
    fi
fi

log_info "最终启动参数: node app.js ${ARGS[*]}"
log_info "工作目录: $(pwd)"
log_info "Node.js版本: $(node --version)"

cd /app

# 启动服务
log_info "🚀 启动 UnblockNeteaseMusic..."
exec node app.js "${ARGS[@]}"