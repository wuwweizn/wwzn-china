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

# 安装系统包和编译依赖
RUN apk add --no-cache \
    bash \
    curl \
    git \
    tzdata \
    jq \
    gcc \
    g++ \
    musl-dev \
    linux-headers \
    libffi-dev \
    openssl-dev \
    jpeg-dev \
    zlib-dev \
    freetype-dev \
    lapack-dev \
    gfortran \
    pkgconfig \
    && rm -rf /var/cache/apk/*

# 创建工作目录
WORKDIR /app

# 升级 pip 和安装构建工具
RUN pip install --upgrade pip setuptools wheel

# 分批安装 Python 依赖（避免内存问题）
RUN pip install --no-cache-dir requests beautifulsoup4 lxml flask
RUN pip install --no-cache-dir schedule python-dateutil pytz
RUN pip install --no-cache-dir selenium webdriver-manager
RUN pip install --no-cache-dir Pillow
RUN pip install --no-cache-dir pymysql || echo "pymysql failed, continuing..."
RUN pip install --no-cache-dir mysql-connector-python || echo "mysql-connector failed, continuing..."
RUN pip install --no-cache-dir paho-mqtt cryptography urllib3 certifi
RUN pip install --no-cache-dir numpy || echo "numpy failed, continuing..."
RUN pip install --no-cache-dir opencv-python-headless || echo "opencv failed, continuing..."
RUN pip install --no-cache-dir onnxruntime || echo "onnxruntime failed, continuing..."

# 从源仓库获取代码
RUN git clone https://github.com/ARC-MX/sgcc_electricity_new.git /tmp/source && \
    cp -r /tmp/source/* . && \
    rm -rf /tmp/source && \
    ls -la /app/ && \
    echo "Source code structure:" && \
    find /app -name "*.py" | head -10

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