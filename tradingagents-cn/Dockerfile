FROM python:3.11-slim

# 设置环境变量
ENV LANG=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    jq \
    build-essential \
    pandoc \
    wkhtmltopdf \
    xvfb \
    fonts-wqy-zenhei \
    fonts-wqy-microhei \
    fonts-liberation \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /opt/tradingagents

# 克隆项目
RUN git clone https://github.com/hsliuping/TradingAgents-CN.git . && \
    git checkout main

# 安装Python依赖
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir pytdx && \
    (pip install --no-cache-dir -r requirements_db.txt || echo "Database requirements optional")

# 创建启动脚本
RUN echo '#!/bin/bash\n\
# 启动Xvfb虚拟显示器（如果可用）\n\
if command -v Xvfb >/dev/null 2>&1; then\n\
    Xvfb :99 -screen 0 1024x768x24 -ac +extension GLX &\n\
    export DISPLAY=:99\n\
    echo "Xvfb started on :99"\n\
else\n\
    echo "Xvfb not available, PDF export may not work"\n\
fi\n\
\n\
# 解析配置\n\
OPTIONS_FILE="/data/options.json"\n\
if [[ -f "$OPTIONS_FILE" ]]; then\n\
    DASHSCOPE_API_KEY=$(cat "$OPTIONS_FILE" | jq -r ".dashscope_api_key // \"\"")\n\
    TUSHARE_TOKEN=$(cat "$OPTIONS_FILE" | jq -r ".tushare_token // \"\"")\n\
    FINNHUB_API_KEY=$(cat "$OPTIONS_FILE" | jq -r ".finnhub_api_key // \"\"")\n\
    GOOGLE_API_KEY=$(cat "$OPTIONS_FILE" | jq -r ".google_api_key // \"\"")\n\
    OPENAI_API_KEY=$(cat "$OPTIONS_FILE" | jq -r ".openai_api_key // \"\"")\n\
    ANTHROPIC_API_KEY=$(cat "$OPTIONS_FILE" | jq -r ".anthropic_api_key // \"\"")\n\
    MONGODB_ENABLED=$(cat "$OPTIONS_FILE" | jq -r ".mongodb_enabled // false")\n\
    REDIS_ENABLED=$(cat "$OPTIONS_FILE" | jq -r ".redis_enabled // false")\n\
    MONGODB_HOST=$(cat "$OPTIONS_FILE" | jq -r ".mongodb_host // \"localhost\"")\n\
    MONGODB_PORT=$(cat "$OPTIONS_FILE" | jq -r ".mongodb_port // 27017")\n\
    REDIS_HOST=$(cat "$OPTIONS_FILE" | jq -r ".redis_host // \"localhost\"")\n\
    REDIS_PORT=$(cat "$OPTIONS_FILE" | jq -r ".redis_port // 6379")\n\
    LOG_LEVEL=$(cat "$OPTIONS_FILE" | jq -r ".log_level // \"info\"")\n\
else\n\
    echo "No configuration file found, using defaults"\n\
fi\n\
\n\
# 创建.env文件\n\
ENV_FILE="/opt/tradingagents/.env"\n\
cat > "$ENV_FILE" <<EOF\n\
DASHSCOPE_API_KEY=${DASHSCOPE_API_KEY}\n\
TUSHARE_TOKEN=${TUSHARE_TOKEN}\n\
FINNHUB_API_KEY=${FINNHUB_API_KEY}\n\
GOOGLE_API_KEY=${GOOGLE_API_KEY}\n\
OPENAI_API_KEY=${OPENAI_API_KEY}\n\
ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}\n\
MONGODB_ENABLED=${MONGODB_ENABLED}\n\
REDIS_ENABLED=${REDIS_ENABLED}\n\
MONGODB_HOST=${MONGODB_HOST}\n\
MONGODB_PORT=${MONGODB_PORT}\n\
REDIS_HOST=${REDIS_HOST}\n\
REDIS_PORT=${REDIS_PORT}\n\
TRADING_AGENTS_DATA_DIR=/data/tradingagents\n\
LOG_LEVEL=${LOG_LEVEL}\n\
MONGODB_DATABASE=trading_agents\n\
MONGODB_USERNAME=\n\
MONGODB_PASSWORD=\n\
REDIS_PASSWORD=\n\
REDIS_DB=0\n\
DOCKER_CONTAINER=true\n\
EOF\n\
\n\
echo "Configuration loaded:"\n\
echo "- DASHSCOPE_API_KEY: ${DASHSCOPE_API_KEY:0:10}..."\n\
echo "- TUSHARE_TOKEN: ${TUSHARE_TOKEN:0:10}..."\n\
echo "- FINNHUB_API_KEY: ${FINNHUB_API_KEY:0:10}..."\n\
\n\
# 确保数据目录存在\n\
mkdir -p /data/tradingagents\n\
\n\
# 启动应用\n\
cd /opt/tradingagents\n\
echo "Starting TradingAgents-CN..."\n\
exec python -m streamlit run web/app.py \\\n\
    --server.address 0.0.0.0 \\\n\
    --server.port 8501 \\\n\
    --server.headless true \\\n\
    --server.enableCORS false \\\n\
    --server.enableXsrfProtection false \\\n\
    --server.fileWatcherType none\n\
' > /usr/local/bin/start.sh && chmod +x /usr/local/bin/start.sh

# 创建数据目录
RUN mkdir -p /data/tradingagents && \
    mkdir -p /config/tradingagents

# 暴露端口
EXPOSE 8501

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8501/_stcore/health || exit 1

# 设置标签
LABEL \
    io.hass.name="TradingAgents-CN" \
    io.hass.description="基于多智能体LLM的中文金融交易框架" \
    io.hass.arch="${TARGETARCH}" \
    io.hass.type="addon" \
    io.hass.version="1.0.1" \
    maintainer="wuwweizn"

# 直接启动应用
CMD ["/usr/local/bin/start.sh"]