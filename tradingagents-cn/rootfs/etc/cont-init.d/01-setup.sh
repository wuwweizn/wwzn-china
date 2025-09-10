#!/bin/bash

# 由于使用标准镜像，需要手动解析选项
OPTIONS_FILE="/data/options.json"

# 检查配置文件是否存在
if [[ ! -f "$OPTIONS_FILE" ]]; then
    echo "Configuration file not found: $OPTIONS_FILE"
    echo "Creating default configuration..."
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

# 解析配置选项
DASHSCOPE_API_KEY=$(cat "$OPTIONS_FILE" | jq -r '.dashscope_api_key // ""')
FINNHUB_API_KEY=$(cat "$OPTIONS_FILE" | jq -r '.finnhub_api_key // ""')
GOOGLE_API_KEY=$(cat "$OPTIONS_FILE" | jq -r '.google_api_key // ""')
OPENAI_API_KEY=$(cat "$OPTIONS_FILE" | jq -r '.openai_api_key // ""')
ANTHROPIC_API_KEY=$(cat "$OPTIONS_FILE" | jq -r '.anthropic_api_key // ""')
MONGODB_ENABLED=$(cat "$OPTIONS_FILE" | jq -r '.mongodb_enabled // false')
REDIS_ENABLED=$(cat "$OPTIONS_FILE" | jq -r '.redis_enabled // false')
MONGODB_HOST=$(cat "$OPTIONS_FILE" | jq -r '.mongodb_host // "localhost"')
MONGODB_PORT=$(cat "$OPTIONS_FILE" | jq -r '.mongodb_port // 27017')
REDIS_HOST=$(cat "$OPTIONS_FILE" | jq -r '.redis_host // "localhost"')
REDIS_PORT=$(cat "$OPTIONS_FILE" | jq -r '.redis_port // 6379')
LOG_LEVEL=$(cat "$OPTIONS_FILE" | jq -r '.log_level // "info"')

echo "Setting up TradingAgents-CN..."

# 创建.env配置文件
ENV_FILE="/opt/tradingagents/.env"
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

# Data Directory
TRADING_AGENTS_DATA_DIR=/data/tradingagents

# Logging
LOG_LEVEL=${LOG_LEVEL}

# MongoDB详细配置
MONGODB_DATABASE=trading_agents
MONGODB_USERNAME=
MONGODB_PASSWORD=

# Redis详细配置
REDIS_PASSWORD=
REDIS_DB=0
EOF

echo "Environment configuration created"

# 确保数据目录存在
mkdir -p /data/tradingagents
mkdir -p /config/tradingagents

# 设置权限
chown -R root:root /opt/tradingagents
chmod 644 "$ENV_FILE"

echo "TradingAgents-CN setup completed"