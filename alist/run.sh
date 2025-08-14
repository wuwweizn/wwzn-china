#!/usr/bin/env bash
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

log_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
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
    CUSTOM_CONFIG=$(jq -r '.custom_config // {}' $CONFIG_PATH)
else
    log_warn "配置文件不存在，使用默认配置"
    WEB_PORT=5244
    ADMIN_USERNAME="admin"
    ADMIN_PASSWORD=""
    LOG_LEVEL="INFO"
    ENABLE_ARIA2=false
    ENABLE_FFMPEG=false
    ENABLE_WEBDAV=true
    CUSTOM_CONFIG="{}"
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

# 创建必要的目录
mkdir -p "$ALIST_DATA_DIR/data"
mkdir -p "$ALIST_DATA_DIR/log"
mkdir -p "/downloads"

# 设置文件权限
chown -R alist:alist "$ALIST_DATA_DIR" "/downloads" 2>/dev/null || true

# 设置环境变量
export ALIST_DATA="$ALIST_DATA_DIR/data"

# 检查Alist版本
log_info "Alist版本: $(/opt/alist/alist version 2>/dev/null | head -n 1 || echo 'Unknown')"

# 初始化配置
if [ ! -f "$ALIST_DATA_DIR/data/config.json" ]; then
    log_info "首次启动，初始化Alist配置..."
    
    # 切换到alist用户运行初始化
    su-exec alist:alist /opt/alist/alist admin --data "$ALIST_DATA_DIR/data" || true
    
    # 等待配置文件生成
    sleep 2
    
    # 如果用户设置了密码，则设置密码
    if [ -n "$ADMIN_PASSWORD" ] && [ "$ADMIN_PASSWORD" != "" ]; then
        log_info "设置管理员密码..."
        su-exec alist:alist /opt/alist/alist admin set "$ADMIN_PASSWORD" --data "$ALIST_DATA_DIR/data" || log_warn "密码设置失败"
    else
        log_warn "未设置管理员密码，请在首次访问时查看日志获取随机生成的密码"
        log_info "或通过以下命令设置密码: docker exec -it alist_container /opt/alist/alist admin set YOUR_PASSWORD --data /config/alist/data"
    fi
fi

# 创建配置文件模板（如果不存在）
CONFIG_FILE="$ALIST_DATA_DIR/data/config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    log_info "创建默认配置文件..."
    cat > "$CONFIG_FILE" << EOF
{
  "force": false,
  "address": "0.0.0.0",
  "port": $WEB_PORT,
  "jwt_secret": "$(openssl rand -hex 16)",
  "token_expires_in": 48,
  "database": {
    "type": "sqlite3",
    "host": "",
    "port": 0,
    "user": "",
    "password": "",
    "name": "data.db",
    "db_file": "data.db",
    "table_prefix": "x_",
    "ssl_mode": ""
  },
  "scheme": {
    "address": "0.0.0.0",
    "https_port": 5245,
    "force_https": false,
    "cert_file": "",
    "key_file": "",
    "unix_file": "",
    "unix_file_perm": ""
  },
  "temp_dir": "temp",
  "bleve_dir": "bleve",
  "log": {
    "enable": true,
    "name": "../log/alist.log",
    "max_size": 50,
    "max_backups": 30,
    "max_age": 28,
    "compress": false
  },
  "delayed_start": 0,
  "max_connections": 0,
  "tls_insecure_skip_verify": true,
  "tasks": {
    "download": {
      "workers": 5,
      "max_retry": 1
    },
    "transfer": {
      "workers": 5,
      "max_retry": 2
    },
    "upload": {
      "workers": 5,
      "max_retry": 0
    },
    "copy": {
      "workers": 5,
      "max_retry": 2
    }
  },
  "cors": {
    "allow_origins": ["*"],
    "allow_methods": ["*"],
    "allow_headers": ["*"]
  },
  "s3": {
    "enable": false,
    "port": 5246,
    "ssl": false
  }
}
EOF
    chown alist:alist "$CONFIG_FILE"
fi

# 启动前检查
if ! command -v /opt/alist/alist &> /dev/null; then
    log_error "Alist二进制文件不存在!"
    exit 1
fi

# 显示管理员信息（如果未设置密码）
if [ -z "$ADMIN_PASSWORD" ] || [ "$ADMIN_PASSWORD" = "" ]; then
    log_info "获取管理员账号信息..."
    su-exec alist:alist /opt/alist/alist admin --data "$ALIST_DATA_DIR/data" || true
fi

# 设置Aria2（如果启用）
if [ "$ENABLE_ARIA2" = "true" ]; then
    log_info "启用Aria2离线下载支持..."
    export RUN_ARIA2=true
    # 启动aria2
    nohup aria2c --enable-rpc --rpc-allow-origin-all --rpc-listen-all --rpc-listen-port=6800 --dir=/downloads &
fi

# 设置FFmpeg环境变量（如果启用）
if [ "$ENABLE_FFMPEG" = "true" ]; then
    log_info "启用FFmpeg视频处理支持..."
    export PATH="/usr/bin:$PATH"
fi

# 启动Alist
log_info "启动Alist服务..."
log_info "访问地址: http://localhost:$WEB_PORT"
log_info "数据目录: $ALIST_DATA_DIR/data"

# 切换到alist用户运行服务
exec su-exec alist:alist /opt/alist/alist server --data "$ALIST_DATA_DIR/data"