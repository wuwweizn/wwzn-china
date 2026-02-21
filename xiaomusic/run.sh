#!/bin/bash
set -e

# ─── 读取环境变量（由 config.yaml 的 options/environment 注入）─────────────────
PUBLIC_PORT="${XIAOMUSIC_PUBLIC_PORT:-58090}"
MUSIC_DIR="${XIAOMUSIC_MUSIC_PATH:-/share/xiaomusic/music}"
CONF_DIR="${XIAOMUSIC_CONF_PATH:-/config/xiaomusic}"

# ─── 确保目录存在 ─────────────────────────────────────────────────────────────
mkdir -p "${MUSIC_DIR}" "${CONF_DIR}"

echo "===================================="
echo "  XiaoMusic Add-on 正在启动..."
echo "  Web 管理界面端口: ${PUBLIC_PORT}"
echo "  音乐目录: ${MUSIC_DIR}"
echo "  配置目录: ${CONF_DIR}"
echo "===================================="
echo "  初次使用请访问: http://homeassistant.local:${PUBLIC_PORT}"
echo "  在 Web 页面输入小米账号密码后方可使用。"
echo "===================================="

# ─── 启动 XiaoMusic ──────────────────────────────────────────────────────────
exec python3 /app/xiaomusic.py \
    --port 8090 \
    --public_port "${PUBLIC_PORT}" \
    --music_path "${MUSIC_DIR}" \
    --conf_path "${CONF_DIR}"
