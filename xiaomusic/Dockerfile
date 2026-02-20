# =====================================================================
# XiaoMusic Home Assistant Add-on Dockerfile
#
# 基于 HA 官方 base 镜像（自带 bashio），安装 xiaomusic pip 包
# run.sh 在启动时读取用户配置，动态挂载音乐目录并启动服务
# =====================================================================

ARG BUILD_FROM
FROM ${BUILD_FROM}

# 安装系统依赖
RUN apk add --no-cache \
    python3 \
    py3-pip \
    ffmpeg \
    gcc \
    musl-dev \
    python3-dev \
    libffi-dev \
    openssl-dev

# 安装 xiaomusic（固定版本，与 config.yaml 中 version 对应）
RUN pip3 install --no-cache-dir --break-system-packages xiaomusic

# 复制启动脚本
COPY run.sh /
RUN chmod a+x /run.sh

# 暴露服务端口
EXPOSE 8090

CMD [ "/run.sh" ]
