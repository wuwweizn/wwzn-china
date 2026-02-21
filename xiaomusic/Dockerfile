# ============================================================
# XiaoMusic HA Addon Dockerfile
# 基于 hanxi/xiaomusic 官方镜像进行封装，适配 HA Addon 结构
# ============================================================
ARG BUILD_FROM
FROM hanxi/xiaomusic:latest

# 复制启动脚本
COPY run.sh /run.sh
RUN chmod +x /run.sh

# 容器内服务端口
EXPOSE 8090

CMD ["/run.sh"]
