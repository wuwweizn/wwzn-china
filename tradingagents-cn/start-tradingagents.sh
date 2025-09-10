#!/usr/bin/env bash
set -e

# 设置工作目录
cd /opt/tradingagents

# 可选：加载环境变量
if [ -f /config/tradingagents/.env ]; then
    export $(cat /config/tradingagents/.env | xargs)
fi

# 启动 Streamlit WebUI
exec streamlit run /opt/tradingagents/app.py \
    --server.port 8501 \
    --server.address 0.0.0.0 \
    --server.headless true
