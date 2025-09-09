#!/usr/bin/with-contenv bashio

# 获取配置选项
DASHSCOPE_API_KEY=$(bashio::config 'dashscope_api_key')
FINNHUB_API_KEY=$(bashio::config 'finnhub_api_key')
GOOGLE_API_KEY=$(bashio::config 'google_api_key')
OPENAI_API_KEY=$(bashio::config 'openai_api_key')
ANTHROPIC_API_KEY=$(bashio::config 'anthropic_api_key')
MONGODB_ENABLED=$(bashio::config 'mongodb_enabled')
REDIS_ENABLED=$(bashio::config 'redis_enabled')
MONGODB_HOST=$(bashio::config 'mongodb_host')
MONGODB_PORT=$(bashio::config 'mongodb_port')
REDIS_HOST=$(bashio::config 'redis_host')
REDIS_PORT=$(bashio::config 'redis_port')
LOG_LEVEL=$(bashio::config 'log_level')

# 设置日志级别
bashio::log.info "Setting up TradingAgents-CN..."

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

bashio::log.info "Environment configuration created"

# 确保数据目录存在
mkdir -p /data/tradingagents
mkdir -p /config/tradingagents

# 设置权限
chown -R root:root /opt/tradingagents
chmod 644 "$ENV_FILE"

bashio::log.info "TradingAgents-CN setup completed"