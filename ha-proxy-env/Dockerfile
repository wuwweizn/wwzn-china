ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM $BUILD_FROM

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# 设置环境变量脚本
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD [ "/run.sh" ]
