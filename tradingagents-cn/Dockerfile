# Home Assistant 插件常用写法：通过 BUILD_FROM 注入基础镜像
ARG BUILD_FROM=ghcr.io/hassio-addons/base:14.0.4
FROM ${BUILD_FROM}

# 允许在构建时指定上游分支/Tag（缺省 main）
ARG TA_REF=main
ENV TA_REF=${TA_REF}

# 安装必要构建依赖（已包含 python3/pip）
RUN apk update && apk add --no-cache \
      git \
      build-base \
      python3-dev \
      libffi-dev \
      cmake

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
