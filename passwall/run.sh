#!/bin/sh

# 启动 uhttpd (OpenWrt Web 服务器)
if [ -f /etc/init.d/uhttpd ]; then
    /etc/init.d/uhttpd start
fi

# 启动 passwall（如果镜像里可执行）
if [ -f /usr/bin/passwall ]; then
    /usr/bin/passwall -f &
fi

# 保持容器运行
tail -f /dev/null
