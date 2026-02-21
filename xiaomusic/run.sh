#!/usr/bin/with-contenv bashio

# ========== 从 HA 插件配置读取参数 ==========
HOSTNAME=$(bashio::config 'XIAOMUSIC_HOSTNAME')
PORT=$(bashio::config 'XIAOMUSIC_PORT')
PUBLIC_PORT=$(bashio::config 'XIAOMUSIC_PUBLIC_PORT')
ACCOUNT=$(bashio::config 'XIAOMUSIC_ACCOUNT')
PASSWORD=$(bashio::config 'XIAOMUSIC_PASSWORD')
MI_DID=$(bashio::config 'XIAOMUSIC_MI_DID')
MUSIC_PATH=$(bashio::config 'XIAOMUSIC_MUSIC_PATH')
CONF_PATH=$(bashio::config 'XIAOMUSIC_CONF_PATH')
VERBOSE=$(bashio::config 'XIAOMUSIC_VERBOSE')

# ========== 创建必要目录 ==========
mkdir -p "${MUSIC_PATH}"
mkdir -p "${CONF_PATH}"

# ========== 导出环境变量（xiaomusic 通过环境变量读取配置）==========
export XIAOMUSIC_PORT="${PORT}"
export XIAOMUSIC_PUBLIC_PORT="${PUBLIC_PORT}"
export XIAOMUSIC_MUSIC_PATH="${MUSIC_PATH}"
export XIAOMUSIC_CONF_PATH="${CONF_PATH}"

if bashio::var.has_value "${HOSTNAME}"; then
    export XIAOMUSIC_HOSTNAME="${HOSTNAME}"
fi

if bashio::var.has_value "${ACCOUNT}"; then
    export XIAOMUSIC_ACCOUNT="${ACCOUNT}"
fi

if bashio::var.has_value "${PASSWORD}"; then
    export XIAOMUSIC_PASSWORD="${PASSWORD}"
fi

if bashio::var.has_value "${MI_DID}"; then
    export XIAOMUSIC_MI_DID="${MI_DID}"
fi

if bashio::var.true "${VERBOSE}"; then
    export XIAOMUSIC_VERBOSE="true"
fi

# ========== 启动 xiaomusic ==========
bashio::log.info "正在启动 XiaoMusic..."
bashio::log.info "音乐目录: ${MUSIC_PATH}"
bashio::log.info "配置目录: ${CONF_PATH}"
bashio::log.info "端口: ${PORT}"

exec xiaomusic
