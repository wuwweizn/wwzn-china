#!/bin/bash

# 设置颜色输出
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 读取环境变量，设置默认值
PORT=${PORT:-8080}
HOST=${HOST:-"0.0.0.0"}
SOURCE_ORDER=${SOURCE_ORDER:-"kuwo kugou migu"}
STRICT=${STRICT:-"false"}
ENDPOINT=${ENDPOINT:-""}
LOG_LEVEL=${LOG_LEVEL:-"info"}

log_info "=== UnblockNeteaseMusic 启动 ==="
log_info "端口: ${PORT}"
log_info "地址: ${HOST}"
log_info "音源: ${SOURCE_ORDER}"

# 检查app.js是否存在
if [ ! -f "/app/app.js" ]; then
    log_error "❌ /app/app.js 不存在!"
    exit 1
fi

# 设置环境变量
export NODE_ENV="production"
export ENABLE_LOCAL_VIP=1

# 构建启动参数 - 使用正确的短参数格式
ARGS=()

# 端口参数
ARGS+=("-p" "${PORT}")

# 地址参数  
ARGS+=("-a" "${HOST}")

# 音源参数
if [ -n "${SOURCE_ORDER}" ]; then
    ARGS+=("-o")
    for source in ${SOURCE_ORDER}; do
        ARGS+=("${source}")
        log_info "添加音源: ${source}"
    done
fi

# 严格模式
if [ "${STRICT}" = "true" ]; then
    ARGS+=("-s")
    log_info "启用严格模式"
fi

# 自定义端点
if [ -n "${ENDPOINT}" ] && [ "${ENDPOINT}" != "" ]; then
    ARGS+=("-e" "${ENDPOINT}")
    log_info "自定义端点: ${ENDPOINT}"
fi

log_info "启动参数: node app.js ${ARGS[*]}"

# 切换到应用目录
cd /app

# 启动应用
log_info "🚀 启动 UnblockNeteaseMusic..."
exec node app.js "${ARGS[@]}"