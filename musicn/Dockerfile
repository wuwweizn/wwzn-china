ARG BUILD_FROM=alpine:3.21.3
FROM ${BUILD_FROM}

# 设置环境
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    TZ=Asia/Shanghai

# 安装必要工具和 Python 编译依赖
RUN apk add --no-cache \
      python3 \
      py3-pip \
      python3-dev \
      build-base \
      libffi-dev \
      openssl-dev \
      gcc \
      g++ \
      make \
      curl \
      git \
      bash \
      tzdata

# 升级 pip
RUN python3 -m pip install --upgrade pip

# 设置工作目录
WORKDIR /opt/app

# 克隆源码（如果你希望 build 时拉最新代码）
ARG REPO_URL=https://github.com/ARC-MX/sgcc_electricity_new
ARG REPO_REF=main
RUN git clone --depth=1 -b ${REPO_REF} ${REPO_URL} /opt/app || echo "源码已存在，跳过"

# 安装 Python 依赖，如果 requirements.txt 存在
RUN if [ -f requirements.txt ]; then \
      pip3 install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple; \
    fi

# 复制启动脚本
COPY run.sh /run.sh
RUN chmod +x /run.sh

# 创建数据目录
RUN mkdir -p /data

# 暴露端口（如果项目有 Web 服务）
EXPOSE 8080

# 默认执行启动脚本
CMD ["/run.sh"]
