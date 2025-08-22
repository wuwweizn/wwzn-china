# 使用标准 Python Alpine 镜像
FROM python:3.11-alpine

# 设置构建参数
ARG BUILD_ARCH
ARG BUILD_VERSION="1.0.0"

# 设置标签
LABEL \
    io.hass.name="SGCC Electricity" \
    io.hass.description="HomeAssistant 国家电网电费查询" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}" \
    maintainer="wuwweizn"

# 设置环境变量
ENV TZ=Asia/Shanghai
ENV PYTHONUNBUFFERED=1

# 安装基本系统包
RUN apk add --no-cache \
    bash \
    curl \
    git \
    tzdata \
    jq

# 创建工作目录
WORKDIR /app

# 复制依赖文件并安装 Python 包
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 从源仓库获取代码
RUN git clone https://github.com/ARC-MX/sgcc_electricity_new.git /tmp/source && \
    cp -r /tmp/source/* . && \
    rm -rf /tmp/source

# 复制启动脚本
COPY run.sh .
RUN chmod +x run.sh

# 创建必要的目录
RUN mkdir -p /data /share

# 设置健康检查
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD pgrep -f python || exit 1

# 暴露端口
EXPOSE 8123

# 启动
CMD ["./run.sh"]