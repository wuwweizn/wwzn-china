# HA Supervisor 要求必须声明 BUILD_FROM 并 FROM $BUILD_FROM
# build.yaml 中会把 BUILD_FROM 指向 hanxi/xiaomusic 官方镜像
ARG BUILD_FROM
FROM $BUILD_FROM

# 安装 jq（用于 run.sh 读取 /data/options.json）
RUN apk add --no-cache jq || apt-get install -y --no-install-recommends jq || true

# 复制启动脚本
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 8090

CMD ["/run.sh"]
