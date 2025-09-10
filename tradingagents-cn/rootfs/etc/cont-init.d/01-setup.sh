#!/bin/bash
set -e

echo "=== TradingAgents-CN Setup Starting ==="

# 配置文件路径
OPTIONS_FILE="/data/options.json"
ENV_FILE="/opt/tradingagents/.env"

# 创建默认配置（如果不存在）
if [[ ! -f "$OPTIONS_FILE" ]]; then
    echo "Creating default configuration..."
    mkdir -p /data
    cat > "$OPTIONS_FILE" <<EOF
{
  "dashscope_api_key": "",
  "finnhub_api_key": "",
  "google_api_key": "",
  "openai_api_key": "",
  "anthropic_api_key": "",
  "mongodb_enabled": false,
  "redis_enabled": false,
  "mongodb_host": "localhost",
  "mongodb_port": 27017,
  "redis_host": "localhost",
  "redis_port": 6379,
  "log_level": "info"
}
EOF
fi

echo "Parsing configuration options..."

# 使用更安全的配置解析
DASHSCOPE_API_KEY=""
FINNHUB_API_KEY=""
GOOGLE_API_KEY=""
OPENAI_API_KEY=""
ANTHROPIC_API_KEY=""
MONGODB_ENABLED="false"
REDIS_ENABLED="false"
MONGODB_HOST="localhost"
MONGODB_PORT="27017"
REDIS_HOST="localhost"
REDIS_PORT="6379"
LOG_LEVEL="info"

# 如果jq可用，使用jq解析
if command -v jq >/dev/null 2>&1; then
    DASHSCOPE_API_KEY=$(jq -r '.dashscope_api_key // ""' "$OPTIONS_FILE")
    FINNHUB_API_KEY=$(jq -r '.finnhub_api_key // ""' "$OPTIONS_FILE")
    GOOGLE_API_KEY=$(jq -r '.google_api_key // ""' "$OPTIONS_FILE")
    OPENAI_API_KEY=$(jq -r '.openai_api_key // ""' "$OPTIONS_FILE")
    ANTHROPIC_API_KEY=$(jq -r '.anthropic_api_key // ""' "$OPTIONS_FILE")
    MONGODB_ENABLED=$(jq -r '.mongodb_enabled // false' "$OPTIONS_FILE")
    REDIS_ENABLED=$(jq -r '.redis_enabled // false' "$OPTIONS_FILE")
    LOG_LEVEL=$(jq -r '.log_level // "info"' "$OPTIONS_FILE")
fi

echo "Creating environment configuration..."

# 创建环境配置文件
cat > "$ENV_FILE" <<EOF
# API Keys
DASHSCOPE_API_KEY=${DASHSCOPE_API_KEY}
FINNHUB_API_KEY=${FINNHUB_API_KEY}
GOOGLE_API_KEY=${GOOGLE_API_KEY}
OPENAI_API_KEY=${OPENAI_API_KEY}
ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}

# Database Configuration
MONGODB_ENABLED=${MONGODB_ENABLED}
REDIS_ENABLED=${REDIS_ENABLED}
MONGODB_HOST=${MONGODB_HOST}
MONGODB_PORT=${MONGODB_PORT}
REDIS_HOST=${REDIS_HOST}
REDIS_PORT=${REDIS_PORT}

# Paths
TRADING_AGENTS_DATA_DIR=/data/tradingagents

# Logging
LOG_LEVEL=${LOG_LEVEL}

# Streamlit Configuration
STREAMLIT_SERVER_ADDRESS=0.0.0.0
STREAMLIT_SERVER_PORT=8501
STREAMLIT_SERVER_HEADLESS=true
EOF

# 确保目录和权限
mkdir -p /data/tradingagents /config/tradingagents /share/tradingagents
chown -R root:root /opt/tradingagents
chmod 644 "$ENV_FILE"

# 测试Python环境
echo "Testing Python environment..."
if /opt/venv/bin/python --version; then
    echo "✓ Python environment OK"
else
    echo "✗ Python environment failed"
    exit 1
fi

# 测试Streamlit
echo "Testing Streamlit installation..."
if /opt/venv/bin/python -c "import streamlit; print(f'Streamlit version: {streamlit.__version__}')"; then
    echo "✓ Streamlit OK"
else
    echo "✗ Streamlit failed"
    # 尝试安装Streamlit
    /opt/venv/bin/pip install streamlit || echo "Failed to install Streamlit"
fi

echo "=== TradingAgents-CN Setup Completed ==="