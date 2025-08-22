#!/bin/bash
set -e

echo "Starting SGCC Electricity addon..."

# 函数：安全读取JSON配置
read_config() {
    local key=$1
    local default=$2
    if [ -f /data/options.json ]; then
        local value=$(cat /data/options.json | jq -r ".$key // \"$default\"")
        if [ "$value" = "null" ]; then
            echo "$default"
        else
            echo "$value"
        fi
    else
        echo "$default"
    fi
}

# 读取配置参数
PHONE=$(read_config "phone" "")
PASSWORD=$(read_config "password" "")
LOGIN_TYPE=$(read_config "login_type" "1")
USER_ID=$(read_config "user_id" "")
CAPTCHA_TYPE=$(read_config "captcha_type" "1")
INTERVAL=$(read_config "interval" "3600")
HA_URL=$(read_config "ha_url" "http://supervisor/core")
HA_TOKEN=$(read_config "ha_token" "")
DB_ENABLE=$(read_config "db_enable" "true")
DB_HOST=$(read_config "db_host" "localhost")
DB_PORT=$(read_config "db_port" "3306")
DB_USERNAME=$(read_config "db_username" "root")
DB_PASSWORD=$(read_config "db_password" "")
DB_DATABASE=$(read_config "db_database" "sgcc")

# 验证必需配置
if [ -z "$PHONE" ] || [ -z "$PASSWORD" ]; then
    echo "ERROR: Phone and password are required!"
    exit 1
fi

if [ -z "$HA_TOKEN" ]; then
    echo "ERROR: Home Assistant token is required!"
    exit 1
fi

echo "Configuration loaded:"
echo "  Phone: $PHONE"
echo "  Login Type: $LOGIN_TYPE"
echo "  Interval: ${INTERVAL}s"
echo "  HA URL: $HA_URL"
echo "  Database: $DB_ENABLE"

# 创建配置文件
cat > /app/config.json << EOF
{
    "phone": "$PHONE",
    "password": "$PASSWORD",
    "login_type": $LOGIN_TYPE,
    "user_id": "$USER_ID",
    "captcha_type": $CAPTCHA_TYPE,
    "interval": $INTERVAL,
    "ha_url": "$HA_URL",
    "ha_token": "$HA_TOKEN",
    "db_enable": $DB_ENABLE,
    "db_host": "$DB_HOST",
    "db_port": $DB_PORT,
    "db_username": "$DB_USERNAME",
    "db_password": "$DB_PASSWORD",
    "db_database": "$DB_DATABASE"
}
EOF

# 确保数据目录存在
mkdir -p /share/sgcc_electricity

echo "Starting SGCC Electricity service..."

# 查找并执行主程序
if [ -f "main.py" ]; then
    echo "Running main.py..."
    exec python3 main.py
elif [ -f "app.py" ]; then
    echo "Running app.py..."
    exec python3 app.py
elif [ -f "run.py" ]; then
    echo "Running run.py..."
    exec python3 run.py
elif [ -f "sgcc.py" ]; then
    echo "Running sgcc.py..."
    exec python3 sgcc.py
else
    echo "Looking for Python files..."
    PYTHON_FILES=$(find . -name "*.py" -type f | head -5)
    echo "Found Python files:"
    echo "$PYTHON_FILES"
    
    # 尝试找到主入口文件
    MAIN_FILE=$(find . -name "*.py" -type f | grep -E "(main|app|run|sgcc|start)" | head -1)
    if [ -n "$MAIN_FILE" ]; then
        echo "Attempting to run: $MAIN_FILE"
        exec python3 "$MAIN_FILE"
    else
        echo "ERROR: No main application file found!"
        echo "Please check the source repository structure."
        exit 1
    fi
fi