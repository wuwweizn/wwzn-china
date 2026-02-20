# HA Supervisor 会传入 BUILD_FROM，但 xiaomusic 是完整镜像，
# 我们直接基于官方多架构镜像进行包装
ARG BUILD_FROM=hanxi/xiaomusic:latest
FROM ${BUILD_FROM}

# 开放 xiaomusic Web UI 端口
EXPOSE 8090

# xiaomusic 官方镜像的启动命令保持不变
# 官方镜像已有 CMD/ENTRYPOINT，无需重复指定