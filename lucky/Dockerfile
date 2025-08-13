FROM python:3.11-slim

# 安装必要工具
RUN apt-get update && apt-get install -y git curl && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 复制启动脚本
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# 设置默认启动命令
CMD ["/app/run.sh"]
