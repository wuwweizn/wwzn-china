#!/usr/bin/env bash
set -e

# 检查是否在 Home Assistant 环境中
if command -v bashio &> /dev/null && [ -f /data/options.json ]; then
    # Home Assistant 环境
    echo "Starting SGCC Electricity addon in Home Assistant environment..."
    
    # 读取配置
    CONFIG_PATH=/data/options.json
    PHONE=$(bashio::config 'phone')
    PASSWORD=$(bashio::config 'password')
    LOGIN_TYPE=$(bashio::config 'login_type')
    USER_ID=$(bashio::config 'user_id')
    CAPTCHA_TYPE=$(bashio::config 'captcha_type')
    INTERVAL=$(bashio::config 'interval')
    HA_URL=$(bashio::config 'ha_url')
    HA_TOKEN=$(bashio::config 'ha_token')
    DB_ENABLE=$(bashio::config 'db_enable')
    DB_HOST=$(bashio::config 'db_host')
    DB_PORT=$(bashio::config 'db_port')
    DB_USERNAME=$(bashio::config 'db_username')
    DB_PASSWORD=$(bashio::config 'db_password')
    DB_DATABASE=$(bashio::config 'db_database')
    
    # 验证必需的配置
    if [[ -z "$PHONE" ]] || [[ -z "$PASSWORD" ]]; then
        bashio::log.fatal "Phone and password are required!"
        exit 1
    fi
    
    if [[ -z "$HA_TOKEN" ]]; then
        bashio::log.fatal "Home Assistant token is required!"
        exit 1
    fi
    
    bashio::log.info "Phone: ${PHONE}"
    bashio::log.info "Login Type: ${LOGIN_TYPE}"
    bashio::log.info "Interval: ${INTERVAL} seconds"
    bashio::log.info "HA URL: ${HA_URL}"
    bashio::log.info "Database Enabled: ${DB_ENABLE}"
else
    # 独立环境
    echo "Starting SGCC Electricity in standalone mode..."
    
    # 设置默认值
    PHONE="${PHONE:-}"
    PASSWORD="${PASSWORD:-}"
    LOGIN_TYPE="${LOGIN_TYPE:-1}"
    USER_ID="${USER_ID:-}"
    CAPTCHA_TYPE="${CAPTCHA_TYPE:-1}"
    INTERVAL="${INTERVAL:-3600}"
    HA_URL="${HA_URL:-http://supervisor/core}"
    HA_TOKEN="${HA_TOKEN:-}"
    DB_ENABLE="${DB_ENABLE:-false}"
    DB_HOST="${DB_HOST:-localhost}"
    DB_PORT="${DB_PORT:-3306}"
    DB_USERNAME="${DB_USERNAME:-root}"
    DB_PASSWORD="${DB_PASSWORD:-}"
    DB_DATABASE="${DB_DATABASE:-sgcc}"
    
    echo "Phone: ${PHONE}"
    echo "Interval: ${INTERVAL} seconds"
    echo "Database Enabled: ${DB_ENABLE}"
fi

# 创建配置文件
cat > /app/config.json << EOF
{
    "phone": "${PHONE}",
    "password": "${PASSWORD}",
    "login_type": ${LOGIN_TYPE},
    "user_id": "${USER_ID}",
    "captcha_type": ${CAPTCHA_TYPE},
    "interval": ${INTERVAL},
    "ha_url": "${HA_URL}",
    "ha_token": "${HA_TOKEN}",
    "db_enable": ${DB_ENABLE},
    "db_host": "${DB_HOST}",
    "db_port": ${DB_PORT},
    "db_username": "${DB_USERNAME}",
    "db_password": "${DB_PASSWORD}",
    "db_database": "${DB_DATABASE}"
}
EOF

# 确保数据目录存在
mkdir -p /share/sgcc_electricity

# 启动应用
bashio::log.info "Starting SGCC Electricity service..."
cd /app

# 根据实际的 sgcc_electricity 应用调整启动命令
# 这里假设应用有一个 main.py 或类似的入口文件
if [[ -f "main.py" ]]; then
    exec python3 main.py
elif [[ -f "app.py" ]]; then
    exec python3 app.py
elif [[ -f "run.py" ]]; then
    exec python3 run.py
else
    bashio::log.error "No main application file found!"
    exit 1
fi