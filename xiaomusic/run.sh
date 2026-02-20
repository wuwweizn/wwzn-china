#!/usr/bin/env bash
# ==============================================================================
# XiaoMusic Add-on 启动脚本
# 注意：使用 bash 而非 with-contenv bashio，因为 xiaomusic 镜像没有 s6-overlay
#
# HA 加载项运行时挂载点：
#   /config  -> HA 配置目录  (config:rw)
#   /media   -> HA 媒体库    (media:rw)
#   /share   -> HA Share目录 (share:rw)
# ==============================================================================

set -e

# bashio 读取配置的辅助函数（替代 with-contenv bashio）
# HA 把加载项选项写入 /data/options.json
config_get() {
    local key="$1"
    local default="$2"
    local val
    val=$(jq -r --arg k "$key" '.[$k] // empty' /data/options.json 2>/dev/null)
    if [ -z "$val" ] || [ "$val" = "null" ]; then
        echo "$default"
    else
        echo "$val"
    fi
}

echo "[XiaoMusic] ===== 启动中 ====="

# ------------------------------------------------------------------------------
# 读取用户配置（来自 /data/options.json）
# ------------------------------------------------------------------------------
PUBLIC_PORT=$(config_get "public_port" "58090")
SONG_MEDIA=$(config_get "song_media" "")
SONG_SHARE=$(config_get "song_share" "")
SONG_DOWNLOAD=$(config_get "song_download" "")

export XIAOMUSIC_PUBLIC_PORT="${PUBLIC_PORT}"
echo "[XiaoMusic] 公网端口: ${PUBLIC_PORT}"

# ------------------------------------------------------------------------------
# 持久化配置目录：/app/conf -> /config/xiaomusic
# ------------------------------------------------------------------------------
mkdir -p /config/xiaomusic

if [ -d /app/conf ] && [ ! -L /app/conf ]; then
    cp -r /app/conf/. /config/xiaomusic/ 2>/dev/null || true
    rm -rf /app/conf
fi

if [ ! -L /app/conf ]; then
    ln -sf /config/xiaomusic /app/conf
fi
echo "[XiaoMusic] 配置目录: /app/conf -> /config/xiaomusic"

# ------------------------------------------------------------------------------
# 音乐目录软链接
# ------------------------------------------------------------------------------
mkdir -p /app/music

# song_media -> /app/music/media_link
MEDIA_LINK="/app/music/media_link"
rm -f "${MEDIA_LINK}"
if [ -n "${SONG_MEDIA}" ]; then
    MEDIA_SRC="/media/${SONG_MEDIA}"
    mkdir -p "${MEDIA_SRC}"
    ln -sf "${MEDIA_SRC}" "${MEDIA_LINK}"
    echo "[XiaoMusic] 音乐目录(media): ${MEDIA_LINK} -> ${MEDIA_SRC}"
else
    ln -sf /media "${MEDIA_LINK}"
    echo "[XiaoMusic] 音乐目录(media): ${MEDIA_LINK} -> /media (全部)"
fi

# song_share -> /app/music/share_link
SHARE_LINK="/app/music/share_link"
rm -f "${SHARE_LINK}"
if [ -n "${SONG_SHARE}" ]; then
    SHARE_SRC="/share/${SONG_SHARE}"
    mkdir -p "${SHARE_SRC}"
    ln -sf "${SHARE_SRC}" "${SHARE_LINK}"
    echo "[XiaoMusic] 音乐目录(share): ${SHARE_LINK} -> ${SHARE_SRC}"
fi

# song_download -> /app/music/download
DOWNLOAD_LINK="/app/music/download"
rm -f "${DOWNLOAD_LINK}"
if [ -n "${SONG_DOWNLOAD}" ]; then
    DOWNLOAD_SRC="/share/${SONG_DOWNLOAD}"
    mkdir -p "${DOWNLOAD_SRC}"
    ln -sf "${DOWNLOAD_SRC}" "${DOWNLOAD_LINK}"
    echo "[XiaoMusic] 下载目录: ${DOWNLOAD_LINK} -> ${DOWNLOAD_SRC}"
else
    mkdir -p /app/music/download
    echo "[XiaoMusic] 下载目录: /app/music/download (容器内)"
fi

# ------------------------------------------------------------------------------
# 启动 xiaomusic
# ------------------------------------------------------------------------------
echo "[XiaoMusic] 启动服务，Web 界面端口: 8090"

exec /app/entrypoint.sh
