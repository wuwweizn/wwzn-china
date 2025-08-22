#!/usr/bin/with-contenv bashio

# 设置日志
bashio::log.info "Starting SGCC Electricity addon..."

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