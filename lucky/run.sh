#!/bin/bash
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# 读取Home Assistant插件选项
CONFIG_PATH=/data/options.json

if [ -f "$CONFIG_PATH" ]; then
    WEB_PORT=$(jq -r '.web_port // 16601' $CONFIG_PATH)
    ADMIN_USERNAME=$(jq -r '.admin_username // "666"' $CONFIG_PATH)
    ADMIN_PASSWORD=$(jq -r '.admin_password // "666"' $CONFIG_PATH)
    LOG_LEVEL=$(jq -r '.log_level // "info"' $CONFIG_PATH)
else
    log_warn "配置文件不存在，使用默认配置"
    WEB_PORT=16601
    ADMIN_USERNAME="666"
    ADMIN_PASSWORD="666"
    LOG_LEVEL="info"
fi

log_info "Lucky Home Assistant 加载项启动中..."
log_info "Web端口: $WEB_PORT"
log_info "管理员用户名: $ADMIN_USERNAME"
log_info "日志级别: $LOG_LEVEL"

# 设置配置目录 - 使用Home Assistant的配置目录
LUCKY_CONFIG_DIR="/config/lucky"
mkdir -p "$LUCKY_CONFIG_DIR"

# 检查配置目录权限
chown -R root:root "$LUCKY_CONFIG_DIR" 2>/dev/null || true

# 设置环境变量以便Lucky使用Home Assistant的配置
export LUCKY_CONFIG_DIR="$LUCKY_CONFIG_DIR"

# 如果是首次运行，创建基础配置
if [ ! -f "$LUCKY_CONFIG_DIR/lucky.conf" ]; then
    log_info "首次启动，等待Lucky初始化配置..."
fi

log_info "Lucky版本: $(lucky -v 2>/dev/null || echo 'Unknown')"

# 切换到配置目录
cd "$LUCKY_CONFIG_DIR"

# 启动Lucky - 使用官方启动方式
log_info "启动Lucky服务..."

# 设置端口环境变量
export PORT="$WEB_PORT"

# 直接启动lucky，让它使用当前目录作为配置目录
exec lucky -cd "$LUCKY_CONFIG_DIR"