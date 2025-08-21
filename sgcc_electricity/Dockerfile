ARG BUILD_FROM=ghcr.io/hassio-addons/base:15.0.6
FROM ${BUILD_FROM}

# 设置工作目录
WORKDIR /usr/src/app

# 安装依赖
RUN apk add --no-cache python3 py3-pip

# 拷贝 sgcc_electricity 代码
COPY . .

# 安装 Python 依赖
RUN pip install --no-cache-dir -r requirements.txt

# 拷贝启动脚本
COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
