#!/usr/bin/with-contenv bashio
# ============================================================
# XiaoMusic Home Assistant Add-on 启动脚本
# 从 /data/options.json 读取用户配置，注入为环境变量
# ============================================================

set -e

bashio::log.info "=== XiaoMusic 加载项启动 ==="

# ---------------------------------------------------------------
# 1. 读取用户在 HA 加载项页面设置的选项
# ---------------------------------------------------------------
MUSIC_PATH=$(bashio::config 'music_path')
CONF_PATH=$(bashio::config 'conf_path')
PUBLIC_PORT=$(bashio::config 'public_port')
HOSTNAME_OVERRIDE=$(bashio::config 'xiaomusic_hostname')

bashio::log.info "音乐目录 (宿主机): ${MUSIC_PATH}"
bashio::log.info "配置目录 (宿主机): ${CONF_PATH}"
bashio::log.info "对外端口: ${PUBLIC_PORT}"

# ---------------------------------------------------------------
# 2. 创建容器内的挂载目录（如果不存在）
# ---------------------------------------------------------------
mkdir -p /app/music
mkdir -p /app/conf

# 尝试创建用户指定路径（如果是容器内可访问路径）
if [ -n "${MUSIC_PATH}" ] && [ "${MUSIC_PATH}" != "/media/xiaomusic/music" ]; then
    mkdir -p "${MUSIC_PATH}" 2>/dev/null || true
fi
if [ -n "${CONF_PATH}" ] && [ "${CONF_PATH}" != "/config/xiaomusic" ]; then
    mkdir -p "${CONF_PATH}" 2>/dev/null || true
fi

# ---------------------------------------------------------------
# 3. 构造软链接：将用户配置路径链接到容器内固定路径
#    xiaomusic 固定读取 /app/music 和 /app/conf
# ---------------------------------------------------------------
if [ -n "${MUSIC_PATH}" ] && [ "${MUSIC_PATH}" != "/app/music" ]; then
    bashio::log.info "建立音乐目录软链接: ${MUSIC_PATH} -> /app/music"
    rm -rf /app/music
    mkdir -p "${MUSIC_PATH}"
    ln -sf "${MUSIC_PATH}" /app/music
fi

if [ -n "${CONF_PATH}" ] && [ "${CONF_PATH}" != "/app/conf" ]; then
    bashio::log.info "建立配置目录软链接: ${CONF_PATH} -> /app/conf"
    rm -rf /app/conf
    mkdir -p "${CONF_PATH}"
    ln -sf "${CONF_PATH}" /app/conf
fi

# ---------------------------------------------------------------
# 4. 导出环境变量供 xiaomusic 使用
# ---------------------------------------------------------------
export XIAOMUSIC_PUBLIC_PORT="${PUBLIC_PORT}"

# 如果用户配置了主机名则导出（用于局域网发现）
if bashio::config.has_value 'xiaomusic_hostname'; then
    export XIAOMUSIC_HOSTNAME="${HOSTNAME_OVERRIDE}"
    bashio::log.info "自定义主机名: ${HOSTNAME_OVERRIDE}"
fi

# ---------------------------------------------------------------
# 5. 启动 xiaomusic
#    官方镜像默认使用 supervisord 管理进程
#    直接调用原始 CMD 入口
# ---------------------------------------------------------------
bashio::log.info "正在启动 XiaoMusic (端口: 8090, 公网端口: ${PUBLIC_PORT})..."
bashio::log.info "Web 管理界面访问地址: http://<HA_IP>:${PUBLIC_PORT}"

# 执行官方镜像的原始启动命令
exec supervisord -c /app/supervisord.conf
