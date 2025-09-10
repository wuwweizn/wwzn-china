ARG BUILD_FROM
FROM $BUILD_FROM

# 设置环境变量
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# 安装系统依赖（Debian/Ubuntu）
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    git \
    curl \
    build-essential \
    libffi-dev \
    libssl-dev \
    jq \
    bash \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /opt/tradingagents

# 克隆项目并处理可能的网络问题
RUN git config --global http.sslVerify false && \
    (git clone https://github.com/hsliuping/TradingAgents-CN.git . || \
     echo "Git clone failed, creating minimal structure") && \
    mkdir -p web

# 创建虚拟环境并安装依赖
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip setuptools wheel

# 安装基础依赖
RUN /opt/venv/bin/pip install streamlit pandas numpy requests || true && \
    if [ -f requirements.txt ]; then /opt/venv/bin/pip install -r requirements.txt || true; fi && \
    /opt/venv/bin/pip install pytdx || true && \
    if [ -f requirements_db.txt ]; then /opt/venv/bin/pip install -r requirements_db.txt || true; fi

# 创建默认应用（如果不存在）
RUN if [ ! -f web/app.py ]; then \
    cat > web/app.py <<EOF && \
import streamlit as st
import sys
import os
import platform

st.set_page_config(
    page_title="TradingAgents-CN",
    page_icon="📈",
    layout="wide"
)

st.title("🚀 TradingAgents-CN")
st.success("应用已成功启动！")

st.info("这是TradingAgents-CN的启动页面。")

col1, col2 = st.columns(2)

with col1:
    st.subheader("🖥️ 系统信息")
    st.code(f"操作系统: {platform.system()} {platform.release()}")
    st.code(f"Python版本: {sys.version}")
    st.code(f"工作目录: {os.getcwd()}")

with col2:
    st.subheader("🔑 环境变量")
    api_keys = {k: v for k, v in os.environ.items() if 'API_KEY' in k}
    if api_keys:
        for k, v in api_keys.items():
            if v:
                st.code(f"{k}: ✅ 已配置")
            else:
                st.code(f"{k}: ❌ 未配置")
    else:
        st.code("未找到API密钥配置")

st.subheader("📝 配置说明")
st.markdown("""
请在Home Assistant加载项配置中设置以下API密钥：
- **dashscope_api_key**: 阿里百炼API密钥（必需）
- **finnhub_api_key**: FinnHub股票数据API密钥（必需）
- **openai_api_key**: OpenAI API密钥（可选）
- **google_api_key**: Google AI API密钥（可选）
- **anthropic_api_key**: Anthropic API密钥（可选）
""")
EOF \
    fi

# 复制配置文件
COPY rootfs /

# 设置权限
RUN chmod +x /etc/services.d/tradingagents/run && \
    chmod +x /etc/services.d/tradingagents/finish && \
    chmod +x /etc/cont-init.d/01-setup.sh && \
    chmod +x /usr/bin/start-tradingagents.sh

# 创建必要目录
RUN mkdir -p /data/tradingagents /config/tradingagents && \
    chown -R root:root /opt/tradingagents

EXPOSE 8501

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=5 \
    CMD curl -f http://localhost:8501/_stcore/health || curl -f http://localhost:8501/ || exit 1

LABEL \
    io.hass.name="TradingAgents-CN" \
    io.hass.description="基于多智能体LLM的中文金融交易框架" \
    io.hass.arch="${TARGETARCH}" \
    io.hass.type="addon" \
    io.hass.version="1.0.0" \
    maintainer="wuwweizn"