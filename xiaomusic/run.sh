#!/usr/bin/with-contenv bashio
# ==============================================================================
# XiaoMusic Add-on 启动脚本
#
# 目录映射说明（HA 加载项运行时的挂载点）：
#   /config  -> HA 配置目录  (config:rw)
#   /media   -> HA 媒体库    (media:rw)
#   /share   -> HA Share目录 (share:rw)
#   /ssl     -> HA SSL证书   (ssl:ro)
#
# xiaomusic 需要的路径：
#   /app/conf  -> 配置文件目录（持久化到 /config/xiaomusic）
#   /app/music -> 音乐扫描根目录（通过软链接接入媒体/share目录）
# ==============================================================================

bashio::log.info "===== XiaoMusic Add-on 正在启动 ====="

# ------------------------------------------------------------------------------
# 读取用户配置
# ------------------------------------------------------------------------------
PUBLIC_PORT=$(bashio::config 'public_port' '58090')
SONG_MEDIA=$(bashio::config 'song_media' '')
SONG_SHARE=$(bashio::config 'song_share' '')
SONG_DOWNLOAD=$(bashio::config 'song_download' '')

export XIAOMUSIC_PUBLIC_PORT="${PUBLIC_PORT}"
bashio::log.info "公网端口: ${PUBLIC_PORT}"

# ------------------------------------------------------------------------------
# 持久化配置目录
# /app/conf  ->  /config/xiaomusic
# 确保 xiaomusic 的 config.json 重启后不丢失
# ------------------------------------------------------------------------------
mkdir -p /config/xiaomusic

if [ -d /app/conf ] && [ ! -L /app/conf ]; then
    # 首次运行：迁移容器内已有配置到 HA 配置目录
    cp -r /app/conf/. /config/xiaomusic/ 2>/dev/null || true
    rm -rf /app/conf
fi

if [ ! -L /app/conf ]; then
    ln -sf /config/xiaomusic /app/conf
fi
bashio::log.info "配置目录: /app/conf -> /config/xiaomusic"

# ------------------------------------------------------------------------------
# 音乐目录软链接
# /app/music 是 xiaomusic 扫描歌曲的根目录
# 通过软链接把 HA 的 /media 或 /share 中的子目录接入进来
# 用户在加载项 UI 中配置：
#   song_media  -> 留空=整个/media，填写=只链接/media/{值}子目录
#   song_share  -> 留空=不链接，填写=链接/share/{值}子目录
# ------------------------------------------------------------------------------
mkdir -p /app/music

# --- song_media 处理 ---
MEDIA_LINK="/app/music/media_link"
rm -f "${MEDIA_LINK}"
if bashio::config.has_value 'song_media'; then
    MEDIA_SRC="/media/${SONG_MEDIA}"
    mkdir -p "${MEDIA_SRC}"
    ln -sf "${MEDIA_SRC}" "${MEDIA_LINK}"
    bashio::log.info "音乐目录(media): ${MEDIA_LINK} -> ${MEDIA_SRC}"
else
    # 未填写时链接整个 /media，方便浏览所有媒体
    ln -sf /media "${MEDIA_LINK}"
    bashio::log.info "音乐目录(media): ${MEDIA_LINK} -> /media (全部)"
fi

# --- song_share 处理 ---
SHARE_LINK="/app/music/share_link"
rm -f "${SHARE_LINK}"
if bashio::config.has_value 'song_share'; then
    SHARE_SRC="/share/${SONG_SHARE}"
    mkdir -p "${SHARE_SRC}"
    ln -sf "${SHARE_SRC}" "${SHARE_LINK}"
    bashio::log.info "音乐目录(share): ${SHARE_LINK} -> ${SHARE_SRC}"
fi

# --- song_download 处理（下载目录）---
DOWNLOAD_LINK="/app/music/download"
rm -f "${DOWNLOAD_LINK}"
if bashio::config.has_value 'song_download'; then
    DOWNLOAD_SRC="/share/${SONG_DOWNLOAD}"
    mkdir -p "${DOWNLOAD_SRC}"
    ln -sf "${DOWNLOAD_SRC}" "${DOWNLOAD_LINK}"
    bashio::log.info "下载目录: ${DOWNLOAD_LINK} -> ${DOWNLOAD_SRC}"
else
    mkdir -p /app/music/download
    bashio::log.info "下载目录: /app/music/download (容器内)"
fi

# ------------------------------------------------------------------------------
# 启动 xiaomusic
# entrypoint.sh 是官方镜像的入口，保持不变
# ------------------------------------------------------------------------------
bashio::log.info "Web 界面: http://$(hostname -i):8090"
bashio::log.info "===== 启动 XiaoMusic ====="

exec /app/entrypoint.sh
