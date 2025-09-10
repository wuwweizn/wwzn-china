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