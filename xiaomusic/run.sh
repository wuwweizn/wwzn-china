#!/usr/bin/env bash
# ============================================================
# XiaoMusic HA Addon 启动脚本
# 读取 HA 加载项配置（/data/options.json），注入为环境变量
# ============================================================
set -e

CONFIG_PATH=/data/options.json

# 读取用户在 HA 页面配置的参数
PUBLIC_PORT=$(jq -r '.public_port // 58090' "${CONFIG_PATH}")
MUSIC_PATH=$(jq -r '.music_path // "/share/xiaomusic/music"' "${CONFIG_PATH}")
CONF_PATH=$(jq -r '.conf_path // "/data/conf"' "${CONFIG_PATH}")
LOG_LEVEL=$(jq -r '.log_level // "warning"' "${CONFIG_PATH}")

# 确保目录存在
mkdir -p "${MUSIC_PATH}" "${CONF_PATH}"

echo "=========================================="
echo " XiaoMusic 加载项启动"
echo " 公共端口 : ${PUBLIC_PORT}"
echo " 音乐目录 : ${MUSIC_PATH}"
echo " 配置目录 : ${CONF_PATH}"
echo " 日志级别 : ${LOG_LEVEL}"
echo "=========================================="

# 将配置作为环境变量传入 xiaomusic
exec env \
  XIAOMUSIC_PUBLIC_PORT="${PUBLIC_PORT}" \
  XIAOMUSIC_MUSIC_PATH="${MUSIC_PATH}" \
  XIAOMUSIC_CONF_PATH="${CONF_PATH}" \
  XIAOMUSIC_LOG_LEVEL="${LOG_LEVEL}" \
  python3 /app/xiaomusic.py \
    --port 8090 \
    --config "${CONF_PATH}/config.json"
