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

# 安装核心 Python 依赖（分批安装，按重要性排序）
RUN pip install --no-cache-dir requests beautifulsoup4 lxml flask
RUN pip install --no-cache-dir schedule python-dateutil pytz
RUN pip install --no-cache-dir selenium webdriver-manager
RUN pip install --no-cache-dir Pillow
RUN pip install --no-cache-dir sympy
RUN pip install --no-cache-dir numpy
RUN pip install --no-cache-dir paho-mqtt cryptography urllib3 certifi

# 安装数据库相关包
RUN pip install --no-cache-dir pymysql || echo "pymysql failed, continuing..."
RUN pip install --no-cache-dir mysql-connector-python || echo "mysql-connector failed, continuing..."

# 安装图像和机器学习相关包（可选）
RUN pip install --no-cache-dir opencv-python-headless || echo "opencv failed, continuing..."
RUN pip install --no-cache-dir onnxruntime || echo "onnxruntime failed, continuing..."

# 从源仓库获取代码
RUN git clone https://github.com/ARC-MX/sgcc_electricity_new.git /tmp/source && \
    cp -r /tmp/source/* . && \
    rm -rf /tmp/source

# 检查源码中的实际 requirements.txt（如果存在）
RUN if [ -f "/app/requirements.txt" ]; then \
        echo "Found requirements.txt in source code:" && \
        cat /app/requirements.txt && \
        echo "Installing additional requirements..." && \
        pip install --no-cache-dir -r /app/requirements.txt || echo "Some requirements failed, continuing..."; \
    fi

# 复制启动脚本
COPY run.sh .
RUN chmod +x run.sh

# 创建必要的目录
RUN mkdir -p /data /share

# 验证关键包是否安装成功
RUN python3 -c "import schedule, selenium, webdriver_manager, sympy; print('Core packages imported successfully')"

# 设置健康检查
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD pgrep -f python || exit 1

# 暴露端口
EXPOSE 8123

# 启动
CMD ["./run.sh"]