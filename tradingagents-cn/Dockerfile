# Home Assistant 插件常用写法：通过 BUILD_FROM 注入基础镜像
ARG BUILD_FROM=ghcr.io/hassio-addons/base:14.0.4
FROM ${BUILD_FROM}


# 允许在构建时指定上游分支/Tag（缺省 main）
ARG TA_REF=main
ENV TA_REF=${TA_REF}


# 基础依赖
RUN apk add --no-cache git python3 py3-pip


# 拉取上游源码
WORKDIR /app
RUN git clone --depth 1 --branch "${TA_REF}" https://github.com/hsliuping/TradingAgents-CN.git /app


# 依赖安装（若无 requirements.txt，可在此改为具体依赖）
RUN if [ -f requirements.txt ]; then \
pip3 install --no-cache-dir -r requirements.txt; \
else \
echo "requirements.txt not found, installing common deps" && \
pip3 install --no-cache-dir streamlit; \
fi


# 暴露 Streamlit 端口
EXPOSE 8501


# 复制 s6 服务与初始化脚本
COPY rootfs /


# 运行时由 s6-overlay 启动（见 rootfs/etc/services.d/tradingagents/run）