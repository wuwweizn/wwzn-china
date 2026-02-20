# ============================================================
# XiaoMusic Home Assistant Add-on Dockerfile
# 基于官方 hanxi/xiaomusic 镜像，加入 HA 加载项运行脚本
# 支持架构: amd64 / aarch64 / armv7
# ============================================================

# 接收来自 build-args 的架构参数
ARG BUILD_ARCH=amd64

# 根据架构选择基础镜像
# 官方 hanxi/xiaomusic 是多架构镜像，docker 会自动选择
FROM hanxi/xiaomusic:latest

# 标注 Label（HA 加载项规范）
ARG BUILD_ARCH
LABEL \
    io.hass.name="XiaoMusic" \
    io.hass.description="使用小爱音箱播放音乐，音乐使用 yt-dlp 下载" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="0.3.101" \
    maintainer="wuwweizn <https://github.com/wuwweizn/wwzn-china>"

# 复制 HA 加载项启动脚本
COPY run.sh /run.sh
RUN chmod +x /run.sh

# 容器内固定端口（勿修改，与 config.yaml 中 ports 对应）
EXPOSE 8090

# 入口点改为我们的启动脚本
CMD ["/run.sh"]
