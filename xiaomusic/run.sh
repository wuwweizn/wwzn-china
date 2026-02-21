#!/usr/bin/env bash
set -e

CONFIG_PATH=/data/options.json

PUBLIC_PORT=$(jq -r '.public_port // 58090' "${CONFIG_PATH}")

mkdir -p /share/xiaomusic/music /data/conf

echo "=========================================="
echo " XiaoMusic 启动中"
echo " 公共端口 : ${PUBLIC_PORT}"
echo " 音乐目录 : /share/xiaomusic/music"
echo " 配置目录 : /data/conf"
echo "=========================================="

exec env \
  XIAOMUSIC_PUBLIC_PORT="${PUBLIC_PORT}" \
  python3 /app/xiaomusic.py \
    --port 8090 \
    --config /data/conf/config.json
