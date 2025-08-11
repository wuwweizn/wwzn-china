#!/bin/bash
echo "启动 DDNSTO 插件..."
TOKEN=$(jq -r '.token' /data/options.json)
echo "Token: $TOKEN"
# 模拟运行
while true; do
  echo "运行中..."
  sleep 60
done
