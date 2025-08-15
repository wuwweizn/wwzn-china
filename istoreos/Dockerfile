ARG BUILD_FROM
ARG BUILD_ARCH

FROM ${BUILD_FROM}

# 安装必要依赖
RUN apk add --no-cache bash curl git python3 py3-pip

# 克隆 istoreos
RUN git clone https://github.com/istoreos/istoreos /opt/istoreos

WORKDIR /opt/istoreos

# 安装 Python 依赖（如果有 requirements.txt）
RUN if [ -f requirements.txt ]; then pip3 install --no-cache-dir -r requirements.txt; fi

# 添加启动脚本
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD [ "/run.sh" ]
