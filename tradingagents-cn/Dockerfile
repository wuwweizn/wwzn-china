ARG BUILD_FROM
FROM $BUILD_FROM

# 设置环境变量
ENV LANG C.UTF-8
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# 检查现有包并安装必需的包
RUN echo "Checking existing packages..." && \
    which python3 || echo "python3 not found" && \
    which pip || echo "pip not found" && \
    which git || echo "git not found" && \
    apk update && \
    apk add --no-cache git curl || echo "Failed to install git/curl"

# 设置工作目录
WORKDIR /opt/tradingagents

# 克隆项目
RUN git clone https://github.com/hsliuping/TradingAgents-CN.git . && \
    git checkout main

# 使用系统pip直接安装（不使用虚拟环境）
RUN pip install --upgrade pip setuptools wheel || \
    python3 -m pip install --upgrade pip setuptools wheel

# 安装Python依赖（最简化方式）
RUN pip install streamlit pandas numpy requests || \
    python3 -m pip install streamlit pandas numpy requests

# 安装项目特定依赖（容错方式）
RUN (pip install -r requirements.txt || echo "Some requirements failed") && \
    (pip install pytdx || echo "pytdx install failed")

# 复制配置文件
COPY rootfs /

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