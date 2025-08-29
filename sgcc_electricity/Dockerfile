FROM python:3.9-alpine

WORKDIR /app

# 安装系统依赖，提供编译环境
RUN apk add --no-cache \
    build-base \
    libffi-dev \
    musl-dev \
    python3-dev \
    gcc \
    g++

# 复制项目文件到容器中
COPY build/sgcc_electricity_new /app

# 安装 Python 依赖，使用国内镜像加速
RUN pip install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# 复制启动脚本
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 8080

CMD ["/run.sh"]
