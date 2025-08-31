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

# 构建启动命令参数 - 使用正确的UnblockNeteaseMusic参数格式
ARGS=()
ARGS+=("-p" "${PORT}")           # 端口参数
ARGS+=("-a" "${HOST}")           # 监听地址参数

# 处理音源参数
if [ -n "${SOURCE_ORDER}" ]; then
    ARGS+=("-o")  # 音源选项
    # 将空格分隔的字符串转换为多个参数
    for source in ${SOURCE_ORDER}; do
        ARGS+=("${source}")
        log_info "添加音源: ${source}"
    done
else
    # 默认音源
    ARGS+=("-o" "kuwo" "kugou" "migu")
    log_info "使用默认音源: kuwo kugou migu"
fi

# 严格模式
if [ "${STRICT}" = "true" ]; then
    ARGS+=("-s")
    log_info "已启用严格模式"
fi

# 自定义端点 - 只有在非空时才添加
if [ -n "${ENDPOINT}" ] && [ "${ENDPOINT}" != "" ]; then
    # 验证是否为有效URL格式
    if [[ "${ENDPOINT}" =~ ^https?:// ]]; then
        ARGS+=("-e" "${ENDPOINT}")
        log_info "使用自定义端点: ${ENDPOINT}"
    else
        log_warn "端点格式无效，忽略: ${ENDPOINT}"
        log_info "使用默认端点"
    fi
else
    log_info "使用默认端点"
fi

# 设置环境变量
export NODE_ENV="production"
export ENABLE_LOCAL_VIP=1

# 设置日志级别
case "${LOG_LEVEL}" in
    "debug")
        export DEBUG="*"
        log_info "启用详细调试模式"
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

# 显示最终启动参数
log_info "启动参数: ${ARGS[*]}"
log_info "环境变量: NODE_ENV=${NODE_ENV}, ENABLE_LOCAL_VIP=${ENABLE_LOCAL_VIP}"

# 创建错误处理函数
handle_error() {
    log_error "❌ 应用异常退出，退出码: $?"
    log_error "请检查网络连接和配置设置"
    exit 1
}

# 设置错误处理
trap handle_error ERR

# 启动服务
log_info "UnblockNeteaseMusic 服务正在启动..."
log_info "服务地址: http://${HOST}:${PORT}"
log_info "---"

cd /app

# 使用exec确保信号正确传递
exec node app.js "${ARGS[@]}"