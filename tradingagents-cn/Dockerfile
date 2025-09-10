ARG BUILD_FROM=ghcr.io/hassio-addons/base:14.0.4
FROM ${BUILD_FROM}

ARG TA_REF=main
ENV TA_REF=${TA_REF}

WORKDIR /app

# 克隆源码
RUN git clone --depth 1 --branch "${TA_REF}" https://github.com/hsliuping/TradingAgents-CN.git /app

# 使用 pip 安装所有 Python 依赖
RUN pip3 install --no-cache-dir -r /app/requirements.txt

EXPOSE 8501

COPY rootfs /
