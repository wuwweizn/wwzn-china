#!/bin/bash
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
    WEB_PORT=$(jq -r '.web_port // 5244' $CONFIG_PATH)
    ADMIN_USERNAME=$(jq -r '.admin_username // "admin"' $CONFIG_PATH)
    ADMIN_PASSWORD=$(jq -r '.admin_password // ""' $CONFIG_PATH)
    LOG_LEVEL=$(jq -r '.log_level // "INFO"' $CONFIG_PATH)
    ENABLE_ARIA2=$(jq -r '.enable_aria2 // false' $CONFIG_PATH)
    ENABLE_FFMPEG=$(jq -r '.enable_ffmpeg // false' $CONFIG_PATH)
    ENABLE_WEBDAV=$(jq -r '.enable_webdav // true' $CONFIG_PATH)
else
    log_warn "配置文件不存在，使用默认配置"
    WEB_PORT=5244
    ADMIN_USERNAME="admin"
    ADMIN_PASSWORD=""
    LOG_LEVEL="INFO"
    ENABLE_ARIA2=false
    ENABLE_FFMPEG=false
    ENABLE_WEBDAV=true
fi

log_info "Alist Home Assistant 加载项启动中..."
log_info "Web端口: $WEB_PORT"
log_info "管理员用户名: $ADMIN_USERNAME"
log_info "日志级别: $LOG_LEVEL"
log_info "启用Aria2: $ENABLE_ARIA2"
log_info "启用FFmpeg: $ENABLE_FFMPEG"
log_info "启用WebDAV: $ENABLE_WEBDAV"

# 设置数据目录 - 使用Home Assistant的配置目录
ALIST_DATA_DIR="/config/alist"
mkdir -p "$ALIST_DATA_DIR"

# 设置环境变量，让Alist使用我们的配置目录
export PUID=0
export PGID=0
export UMASK=022
export TZ=Asia/Shanghai

# 启用的功能环境变量
if [ "$ENABLE_ARIA2" = "true" ]; then
    export RUN_ARIA2=true
    log_info "启用Aria2离线下载支持"
fi

# 设置文件权限
chown -R root:root "$ALIST_DATA_DIR" 2>/dev/null || true

# 检查Alist版本
log_info "Alist版本: $(/opt/alist/alist version 2>/dev/null | head -n 1 || echo 'Unknown')"

# 显示管理员账号信息
if [ ! -f "$ALIST_DATA_DIR/data.db" ]; then
    log_info "首次启动，将显示管理员账号信息..."
    
    # 设置数据目录并启动
    cd "$ALIST_DATA_DIR"
    
    # 如果用户设置了密码，在启动后设置
    if [ -n "$ADMIN_PASSWORD" ] && [ "$ADMIN_PASSWORD" != "" ]; then
        log_info "将设置自定义管理员密码..."
        # 先启动服务生成配置，然后在后台设置密码
        (
            sleep 10
            log_info "设置管理员密码..."
            /opt/alist/alist admin set "$ADMIN_PASSWORD" || log_warn "密码设置失败"
        ) &
    else
        log_warn "未设置管理员密码，启动后请查看日志获取随机生成的密码"
        # 延迟显示管理员信息
        (
            sleep 5
            log_info "获取管理员账号信息..."
            /opt/alist/alist admin || true
        ) &
    fi
fi

# 启动Alist
log_info "启动Alist服务..."
log_info "访问地址: http://localhost:$WEB_PORT"
log_info "数据目录: $ALIST_DATA_DIR"

# 切换到数据目录并启动服务
cd "$ALIST_DATA_DIR"
exec /opt/alist/alist server