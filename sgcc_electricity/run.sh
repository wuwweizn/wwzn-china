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

# 检查已安装的包并补充缺失的包
echo "Checking installed packages..."
pip list | grep -E "(schedule|selenium|webdriver-manager|PIL|opencv|onnx)" || echo "Some packages may be missing"

# 运行时检查并安装关键缺失包
echo "Checking for missing critical packages..."
python3 -c "import onnxruntime" 2>/dev/null || {
    echo "ONNX Runtime missing, attempting to install..."
    pip install --no-cache-dir onnxruntime-cpu || pip install --no-cache-dir onnxruntime || echo "Failed to install onnxruntime"
}

python3 -c "import sympy" 2>/dev/null || {
    echo "SymPy missing, attempting to install..."
    pip install --no-cache-dir sympy || echo "Failed to install sympy"
}

python3 -c "import numpy" 2>/dev/null || {
    echo "NumPy missing, attempting to install..."
    pip install --no-cache-dir numpy || echo "Failed to install numpy"
}

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

# 显示应用结构
echo "Application structure:"
ls -la /app/
if [ -d "scripts" ]; then
    echo "Scripts directory:"
    ls -la /app/scripts/
fi

echo "Starting SGCC Electricity service..."

# 查找并执行主程序
if [ -f "scripts/main.py" ]; then
    echo "Running scripts/main.py..."
    # 设置 Python 路径，确保可以导入 scripts 目录中的模块
    export PYTHONPATH="/app/scripts:/app:$PYTHONPATH"
    cd /app/scripts
    exec python3 main.py
elif [ -f "main.py" ]; then
    echo "Running main.py..."
    export PYTHONPATH="/app:$PYTHONPATH"
    exec python3 main.py
else
    echo "ERROR: No main application file found!"
    echo "Available Python files:"
    find /app -name "*.py" -type f | head -10
    exit 1
fi