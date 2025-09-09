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

# 复制配置文件
COPY rootfs /

# 安装 bashio（Home Assistant 加载项必需）
RUN pip install --no-cache-dir bashio

# 设置权限
RUN chmod +x /etc/services.d/tradingagents/run && \
    chmod +x /etc/services.d/tradingagents/finish && \
    chmod +x /etc/cont-init.d/01-setup.sh && \
    chmod +x /usr/bin/start-tradingagents.sh

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
    io.hass.version="1.0.0" \
    maintainer="wuwweizn"