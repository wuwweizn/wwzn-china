#!/usr/bin/with-contenv bash
# 初始化数据目录
mkdir -p /data/tradingagents
mkdir -p /config/tradingagents

# 设置权限
chown -R root:root /data/tradingagents /config/tradingagents
