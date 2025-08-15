ARG BUILD_ARCH

# 使用已有 Passwall 镜像作为基础
FROM garypang13/openwrt-passwall:${BUILD_ARCH}

# 复制启动脚本
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
