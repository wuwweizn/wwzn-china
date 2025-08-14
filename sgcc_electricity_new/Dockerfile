FROM python:3.9-alpine

WORKDIR /app

# 安装系统依赖（编译工具和库）
RUN apk add --no-cache \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    make \
    bash \
    curl \
    python3-dev

# 复制项目文件
COPY build/sgcc_electricity_new /app

# 安装 Python 依赖
RUN pip install --no-cache-dir -r requirements.txt

# 复制启动脚本
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 8080

CMD ["/run.sh"]
