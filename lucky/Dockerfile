FROM python:3.11-slim

# 安装依赖
RUN apt-get update && apt-get install -y git curl && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 复制源码或程序文件到容器（假设 lucky 源码在当前目录）
COPY . /app

# 安装依赖
RUN pip install --no-cache-dir -r requirements.txt

# 设置默认启动命令，保证 HA 启动时不用 run.sh
CMD ["python3", "-m", "lucky"]
