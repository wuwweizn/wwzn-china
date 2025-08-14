FROM python:3.9-alpine

WORKDIR /app

# 复制项目文件到容器中
COPY build/sgcc_electricity_new /app

# 安装依赖
RUN pip install --no-cache-dir -r requirements.txt

# 复制启动脚本
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 8080

CMD ["/run.sh"]
