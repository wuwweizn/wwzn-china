ARG BUILD_FROM
FROM $BUILD_FROM

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# 复制启动脚本
COPY rootfs /

# 复制 HACS 极速版集成文件（由 CI 在构建前复制到此目录）
COPY hacs/ /hacs/

RUN chmod +x /etc/addon/run
