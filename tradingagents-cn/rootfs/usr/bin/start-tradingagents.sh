#!/bin/bash
set -e

echo "=== Starting TradingAgents-CN Service ==="

# 加载环境变量
if [ -f /opt/tradingagents/.env ]; then
    set -a
    source /opt/tradingagents/.env
    set +a
    echo "✓ Environment loaded"
fi

# 激活虚拟环境
if [ -d /opt/venv ]; then
    source /opt/venv/bin/activate
    echo "✓ Virtual environment activated"
    echo "Python path: $(which python)"
    echo "Python version: $(python --version)"
else
    echo "✗ Virtual environment not found"
    exit 1
fi

# 切换到应用目录
cd /opt/tradingagents || {
    echo "✗ Failed to change to /opt/tradingagents"
    exit 1
}

echo "Current directory: $(pwd)"
echo "Directory contents:"
ls -la

# 检查应用文件
if [ ! -f web/app.py ]; then
    echo "Creating minimal app.py..."
    mkdir -p web
    cat > web/app.py <<EOF
import streamlit as st
import sys
import os

st.set_page_config(
    page_title="TradingAgents-CN",
    page_icon="📈",
    layout="wide"
)

st.title("🚀 TradingAgents-CN")
st.success("应用已成功启动！")

st.info("这是TradingAgents-CN的临时页面。完整功能正在加载中...")

st.subheader("环境信息")
st.code(f"Python版本: {sys.version}")
st.code(f"工作目录: {os.getcwd()}")

st.subheader("环境变量")
env_vars = {k: v for k, v in os.environ.items() if 'API_KEY' in k}
for k, v in env_vars.items():
    if v:
        st.code(f"{k}: {'*' * len(v)}")
    else:
        st.code(f"{k}: 未设置")
EOF
fi

echo "✓ Application file ready"

# 等待网络就绪
echo "Waiting for network..."
sleep 10

# 启动应用
echo "🚀 Starting Streamlit application..."

exec python -m streamlit run web/app.py \
    --server.address 0.0.0.0 \
    --server.port 8501 \
    --server.headless true \
    --server.enableCORS false \
    --server.enableXsrfProtection false \
    --server.fileWatcherType none \
    --server.runOnSave false \
    --global.developmentMode false