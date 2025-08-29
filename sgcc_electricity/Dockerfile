FROM python:3.9-alpine

WORKDIR /app

# 安装编译依赖
RUN apk add --no-cache build-base musl-dev libffi-dev python3-dev

COPY build/sgcc_electricity_new /app

RUN pip install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 8080
CMD ["/run.sh"]
