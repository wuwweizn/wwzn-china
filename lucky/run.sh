#!/usr/bin/env bash
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

# 设置配置目录
LUCKY_CONFIG_DIR="/config/lucky"
mkdir -p "$LUCKY_CONFIG_DIR"

# 如果配置目录为空，创建初始配置
if [ ! -f "$LUCKY_CONFIG_DIR/lucky.conf" ]; then
    log_info "首次启动，创建初始配置..."
    
    # 创建初始配置文件
    cat > "$LUCKY_CONFIG_DIR/lucky.conf" << EOF
{
  "ConfigVersion": "v2.17.8",
  "SafeURL": "/",
  "AdminUsername": "$ADMIN_USERNAME",
  "AdminPassword": "$ADMIN_PASSWORD",
  "WebPort": $WEB_PORT,
  "LogLevel": "$LOG_LEVEL",
  "HTTPSEnable": false,
  "CertPath": "",
  "KeyPath": "",
  "IPWhiteList": [],
  "IPBlackList": [],
  "AllowCORS": true,
  "Language": "zh-CN"
}
EOF
    
    chown -R lucky:lucky "$LUCKY_CONFIG_DIR"
fi

# 设置文件权限
chown -R lucky:lucky /data/lucky "$LUCKY_CONFIG_DIR"

# 检查Lucky版本
log_info "Lucky版本: $(lucky -v 2>/dev/null || echo 'Unknown')"

# 启动前检查
if ! command -v lucky &> /dev/null; then
    log_error "Lucky二进制文件不存在!"
    exit 1
fi

# 启动Lucky
log_info "启动Lucky服务..."
exec su-exec lucky:lucky lucky -cd "$LUCKY_CONFIG_DIR" -p "$WEB_PORT" -u "$ADMIN_USERNAME" -pwd "$ADMIN_PASSWORD"