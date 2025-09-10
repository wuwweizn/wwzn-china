# 使用官方 Home Assistant base，支持 apt
ARG BUILD_FROM=ghcr.io/home-assistant/base:2024.6.0
FROM ${BUILD_FROM}

# 允许在构建时指定上游分支/Tag（缺省 main）
ARG TA_REF=main
ENV TA_REF=${TA_REF}

# 安装必要构建依赖
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       git \
       build-essential \
       python3-dev \
       libffi-dev \
       cmake \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 克隆上游 TradingAgents-CN 源码
RUN git clone --depth 1 --branch "${TA_REF}" https://github.com/hsliuping/TradingAgents-CN.git /app

# 安装 Python 依赖
RUN pip3 install --no-cache-dir -r /app/requirements.txt

# 暴露 Streamlit 默认端口
EXPOSE 8501

# 复制 s6 服务与初始化脚本（用于 HA 插件管理）
COPY rootfs /

# 默认启动交给 s6-overlay
