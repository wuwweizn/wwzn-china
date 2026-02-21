#!/bin/bash
set -e

# ========== 从 HA options.json 读取配置 ==========
OPTIONS_FILE="/data/options.json"

get_option() {
    bashio::config "$1" 2>/dev/null || echo ""
}

HOSTNAME=$(bashio::config 'XIAOMUSIC_HOSTNAME')
PORT=$(bashio::config 'XIAOMUSIC_PORT')
PUBLIC_PORT=$(bashio::config 'XIAOMUSIC_PUBLIC_PORT')
ACCOUNT=$(bashio::config 'XIAOMUSIC_ACCOUNT')
PASSWORD=$(bashio::config 'XIAOMUSIC_PASSWORD')
MI_DID=$(bashio::config 'XIAOMUSIC_MI_DID')
MUSIC_PATH=$(bashio::config 'XIAOMUSIC_MUSIC_PATH')
CONF_PATH=$(bashio::config 'XIAOMUSIC_CONF_PATH')
VERBOSE=$(bashio::config 'XIAOMUSIC_VERBOSE')

# ========== 创建目录 ==========
mkdir -p "${MUSIC_PATH}"
mkdir -p "${CONF_PATH}"

# ========== 导出环境变量 ==========
# 只在有实际值时才导出，避免空字符串或占位符被传入
[ -n "${PORT}" ]        && export XIAOMUSIC_PORT="${PORT}"
[ -n "${PUBLIC_PORT}" ] && export XIAOMUSIC_PUBLIC_PORT="${PUBLIC_PORT}"
[ -n "${MUSIC_PATH}" ]  && export XIAOMUSIC_MUSIC_PATH="${MUSIC_PATH}"
[ -n "${CONF_PATH}" ]   && export XIAOMUSIC_CONF_PATH="${CONF_PATH}"
[ -n "${HOSTNAME}" ]    && export XIAOMUSIC_HOSTNAME="${HOSTNAME}"
[ -n "${ACCOUNT}" ]     && export XIAOMUSIC_ACCOUNT="${ACCOUNT}"
[ -n "${PASSWORD}" ]    && export XIAOMUSIC_PASSWORD="${PASSWORD}"
[ -n "${MI_DID}" ]      && export XIAOMUSIC_MI_DID="${MI_DID}"
[ "${VERBOSE}" = "true" ] && export XIAOMUSIC_VERBOSE="true"

echo "[Info] 启动 XiaoMusic..."
echo "[Info] 音乐目录: ${MUSIC_PATH}"
echo "[Info] 配置目录: ${CONF_PATH}"
echo "[Info] 端口: ${PORT}"

exec xiaomusic
