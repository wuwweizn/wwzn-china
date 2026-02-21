#!/usr/bin/with-contenv bashio

# ─── 读取 Add-on 配置 ─────────────────────────────────────────────────────────
PUBLIC_PORT=$(bashio::config 'XIAOMUSIC_PUBLIC_PORT')

# ─── 设置目录 ─────────────────────────────────────────────────────────────────
MUSIC_DIR="/share/xiaomusic/music"
CONF_DIR="/config/xiaomusic"

mkdir -p "${MUSIC_DIR}" "${CONF_DIR}"

bashio::log.info "===================================="
bashio::log.info "  XiaoMusic Add-on 正在启动..."
bashio::log.info "  Web 管理界面端口: ${PUBLIC_PORT}"
bashio::log.info "  音乐目录: ${MUSIC_DIR}"
bashio::log.info "  配置目录: ${CONF_DIR}"
bashio::log.info "===================================="
bashio::log.info "  初次使用请访问: http://homeassistant.local:${PUBLIC_PORT}"
bashio::log.info "  在 Web 页面输入小米账号密码后方可使用。"
bashio::log.info "===================================="

# ─── 启动 XiaoMusic ──────────────────────────────────────────────────────────
exec python3 -m xiaomusic \
    --port 8090 \
    --public_port "${PUBLIC_PORT}" \
    --music_path "${MUSIC_DIR}" \
    --conf_path "${CONF_DIR}"
