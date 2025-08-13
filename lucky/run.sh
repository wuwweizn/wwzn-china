#!/usr/bin/env bash
set -e

# 可以在这里加初始化逻辑
echo "Starting Lucky Home Assistant Add-on..."

# 运行容器自带的程序
exec /app/run.sh
