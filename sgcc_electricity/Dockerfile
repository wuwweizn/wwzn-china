# 使用更稳定的 Debian slim 镜像
FROM python:3.9-slim

# 设置工作目录
WORKDIR /app

# 安装系统依赖（C 编译工具和常用库）
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libffi-dev \
    libssl-dev \
    curl \
    bash \
    && rm -rf /var/lib/apt/lists/*

# 复制项目文件
COPY build/sgcc_electricity_new /app

# 安装 Python 依赖，使用国内镜像加速
RUN pip install --no-cache-dir -i https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt

# 复制启动脚本并赋予执行权限
COPY run.sh /run.sh
RUN chmod +x /run.sh

# 暴露端口
EXPOSE 8080

# 启动容器时执行脚本
CMD ["/run.sh"]
