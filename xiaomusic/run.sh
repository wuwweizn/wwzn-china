#!/usr/bin/env bash
# ==============================================================================
# XiaoMusic Add-on 启动脚本
#
# 官方镜像启动方式：/app/.venv/bin/python /app/xiaomusic.py
# 环境变量方式配置参数（XIAOMUSIC_PUBLIC_PORT 等）
# HA 加载项挂载点：
#   /config -> HA配置目录
#   /media  -> HA媒体库
#   /share  -> HA Share目录
# /data/options.json -> HA加载项用户配置
# ==============================================================================

set -e

# 读取 /data/options.json 中的配置项
config_get() {
    local key="$1"
    local default="$2"
    local val
    if [ -f /data/options.json ]; then
        val=$(jq -r --arg k "$key" '.[$k] // empty' /data/options.json 2>/dev/null)
    fi
    if [ -z "$val" ] || [ "$val" = "null" ]; then
        echo "$default"
    else
        echo "$val"
    fi
}

echo "[XiaoMusic] ===== 启动中 ====="

# ------------------------------------------------------------------------------
# 读取用户配置
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
if [ ! -e /app/conf ]; then
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
    mkdir -p "/media/${SONG_MEDIA}"
    ln -sf "/media/${SONG_MEDIA}" "${MEDIA_LINK}"
    echo "[XiaoMusic] 音乐(media): ${MEDIA_LINK} -> /media/${SONG_MEDIA}"
else
    ln -sf /media "${MEDIA_LINK}"
    echo "[XiaoMusic] 音乐(media): ${MEDIA_LINK} -> /media"
fi

# song_share -> /app/music/share_link
SHARE_LINK="/app/music/share_link"
rm -f "${SHARE_LINK}"
if [ -n "${SONG_SHARE}" ]; then
    mkdir -p "/share/${SONG_SHARE}"
    ln -sf "/share/${SONG_SHARE}" "${SHARE_LINK}"
    echo "[XiaoMusic] 音乐(share): ${SHARE_LINK} -> /share/${SONG_SHARE}"
fi

# song_download -> /app/music/download
DOWNLOAD_LINK="/app/music/download"
rm -f "${DOWNLOAD_LINK}"
if [ -n "${SONG_DOWNLOAD}" ]; then
    mkdir -p "/share/${SONG_DOWNLOAD}"
    ln -sf "/share/${SONG_DOWNLOAD}" "${DOWNLOAD_LINK}"
    echo "[XiaoMusic] 下载目录: ${DOWNLOAD_LINK} -> /share/${SONG_DOWNLOAD}"
else
    mkdir -p /app/music/download
    echo "[XiaoMusic] 下载目录: /app/music/download (容器内)"
fi

# ------------------------------------------------------------------------------
# 启动 xiaomusic
# 官方镜像使用 .venv 虚拟环境，入口为 /app/xiaomusic.py
# ------------------------------------------------------------------------------
echo "[XiaoMusic] 启动服务..."

# 优先用 supervisord（如果镜像内有），否则直接用 python 启动
if [ -f /usr/bin/supervisord ] || [ -f /usr/local/bin/supervisord ]; then
    echo "[XiaoMusic] 使用 supervisord 启动"
    exec supervisord -c /app/supervisord.conf
elif [ -f /app/.venv/bin/python ]; then
    echo "[XiaoMusic] 使用 .venv python 启动"
    exec /app/.venv/bin/python /app/xiaomusic.py
else
    echo "[XiaoMusic] 使用系统 python 启动"
    exec python3 /app/xiaomusic.py
fi
