ARG BUILD_FROM=ghcr.io/hassio-addons/base:14.0.3
FROM ${BUILD_FROM}

# 镜像内时区与环境
ENV \
  LANG=C.UTF-8 \
  LC_ALL=C.UTF-8 \
  PYTHONUNBUFFERED=1 \
  PIP_NO_CACHE_DIR=1

# 构建参数（可在 build.yaml 中覆盖）
ARG REPO_URL=https://github.com/ARC-MX/sgcc_electricity_new
ARG REPO_REF=main

# 运行所需软件
RUN apk add --no-cache \
      python3 \
      py3-pip \
      git \
      tzdata \
      curl \
      jq \
      bash

# 拉取源码
RUN git clone --depth=1 -b ${REPO_REF} ${REPO_URL} /opt/app
WORKDIR /opt/app

# 如果项目中有 requirements.txt / pyproject.toml，按需安装
# 这两行会自动忽略不存在的文件，不会构建失败
RUN if [ -f requirements.txt ]; then pip3 install -r requirements.txt; fi
RUN if [ -f pyproject.toml ]; then pip3 install .; fi

# 复制启动脚本
COPY run.sh /run.sh
RUN chmod +x /run.sh

# 创建数据目录
RUN mkdir -p /data

# 暴露一个可选端口（如果你的项目包含 Web/HTTP 服务，端口通过选项配置）
EXPOSE 8080

# s6-overlay 将以 /init 作为 ENTRYPOINT，这里使用 CMD 指向我们的启动脚本
CMD [ "/run.sh" ]