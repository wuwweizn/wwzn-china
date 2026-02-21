#!/bin/bash
set -e

# ─── 读取 HA Add-on options（通过环境变量注入，变量名大写）────────────────────
PUBLIC_PORT="${PUBLIC_PORT:-58090}"
MUSIC_DIR="/share/xiaomusic/music"
CONF_DIR="/config/xiaomusic"

mkdir -p "${MUSIC_DIR}" "${CONF_DIR}"

echo "===================================="
echo "  XiaoMusic Add-on 正在启动..."
echo "  Web 管理界面端口: ${PUBLIC_PORT}"
echo "  音乐目录: ${MUSIC_DIR}"
echo "  配置目录: ${CONF_DIR}"
echo "===================================="
echo "  请访问: http://homeassistant.local:${PUBLIC_PORT}"
echo "  初次使用需在 Web 页面填写小米账号密码。"
echo "===================================="

exec python3 /app/xiaomusic.py \
    --port 8090 \
    --public_port "${PUBLIC_PORT}" \
    --music_path "${MUSIC_DIR}" \
    --conf_path "${CONF_DIR}"
