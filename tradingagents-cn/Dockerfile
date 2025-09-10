# TradingAgents-CN 启动问题排查指南

## 问题分析

根据您的配置，启动失败且无日志输出通常是由以下原因造成：

### 1. 主要问题定位

#### A. bashio 依赖问题
当前配置使用了 `bashio` 命令，但基础镜像可能不包含此工具：

```bash
#!/usr/bin/with-contenv bashio
bashio::net.wait_for 8501
bashio::log.info "Starting TradingAgents-CN..."
```

#### B. 虚拟环境问题
虚拟环境可能未正确创建或激活失败。

#### C. 权限问题
脚本权限或文件所有权可能不正确。

## 解决方案

### 方案1：修复现有配置

#### 1.1 修改 Dockerfile

```dockerfile
ARG BUILD_FROM
FROM $BUILD_FROM

# 设置环境变量
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# 安装系统依赖（包含 bashio）
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
    curl \
    build-essential \
    libffi-dev \
    libssl-dev \
    jq \
    bash \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 安装 bashio (Home Assistant CLI工具)
RUN curl -J -L -o /usr/bin/bashio \
    "https://github.com/hassio-addons/bashio/releases/latest/download/bashio" \
    && chmod a+x /usr/bin/bashio

# 设置工作目录
WORKDIR /opt/tradingagents

# 克隆项目并处理可能的网络问题
RUN git config --global http.sslVerify false && \
    git clone https://github.com/hsliuping/TradingAgents-CN.git . || \
    (echo "Git clone failed, creating minimal structure" && \
     mkdir -p web && \
     echo "import streamlit as st; st.write('TradingAgents-CN Loading...')" > web/app.py)

# 创建虚拟环境并安装依赖
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip setuptools wheel

# 安装基础依赖（确保即使requirements.txt不存在也能运行）
RUN /opt/venv/bin/pip install streamlit pandas numpy || true && \
    if [ -f requirements.txt ]; then /opt/venv/bin/pip install -r requirements.txt || true; fi && \
    /opt/venv/bin/pip install pytdx || true && \
    if [ -f requirements_db.txt ]; then /opt/venv/bin/pip install -r requirements_db.txt || true; fi

# 复制配置文件
COPY rootfs /

# 设置权限
RUN chmod +x /etc/services.d/tradingagents/run && \
    chmod +x /etc/services.d/tradingagents/finish && \
    chmod +x /etc/cont-init.d/01-setup.sh && \
    chmod +x /usr/bin/start-tradingagents.sh

# 创建必要目录
RUN mkdir -p /data/tradingagents /config/tradingagents /share/tradingagents && \
    chown -R root:root /opt/tradingagents

# 创建测试脚本
RUN echo '#!/bin/bash\necho "Testing Python environment..."\n/opt/venv/bin/python --version\n/opt/venv/bin/pip list\necho "Environment test completed"' > /usr/bin/test-env.sh && \
    chmod +x /usr/bin/test-env.sh

EXPOSE 8501

# 改进健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=5 \
    CMD curl -f http://localhost:8501/_stcore/health || curl -f http://localhost:8501/ || exit 1

LABEL \
    io.hass.name="TradingAgents-CN" \
    io.hass.description="基于多智能体LLM的中文金融交易框架" \
    io.hass.arch="${TARGETARCH}" \
    io.hass.type="addon" \
    io.hass.version="1.0.0" \
    maintainer="wuwweizn"
```

#### 1.2 修改初始化脚本 (01-setup.sh)

```bash
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
```

#### 1.3 修改服务运行脚本

```bash
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
```

### 方案2：简化版配置（推荐）

如果上述修复仍有问题，建议使用简化的s6-overlay配置：

#### 2.1 简化的服务脚本 (run)

```bash
#!/usr/bin/execlineb -P
with-contenv
exec /usr/bin/start-tradingagents.sh
```

#### 2.2 简化的启动脚本

```bash
#!/bin/bash
set -e

echo "Starting TradingAgents-CN..."

# 基础检查
cd /opt/tradingagents

# 激活虚拟环境
source /opt/venv/bin/activate

# 简单的应用启动
exec streamlit run web/app.py --server.address 0.0.0.0 --server.port 8501 --server.headless true
```

## 调试步骤

### 1. 检查容器状态

```bash
# 在Home Assistant中查看详细日志
docker logs addon_<addon_id> -f

# 或者进入容器调试
docker exec -it addon_<addon_id> /bin/bash
```

### 2. 测试环境

进入容器后执行：

```bash
# 测试Python
/opt/venv/bin/python --version

# 测试Streamlit
/opt/venv/bin/python -c "import streamlit; print('OK')"

# 手动启动应用
cd /opt/tradingagents
/opt/venv/bin/python -m streamlit run web/app.py --server.port 8501
```

### 3. 检查文件权限

```bash
ls -la /etc/services.d/tradingagents/
ls -la /usr/bin/start-tradingagents.sh
```

## 临时解决方案

如果仍有问题，可以创建一个最小化的版本来测试：

1. 先确保基础Docker镜像能正常启动
2. 逐步添加功能
3. 使用简单的Python HTTP服务器作为测试

这样可以逐步定位问题所在。