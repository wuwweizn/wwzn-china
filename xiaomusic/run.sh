#!/bin/bash
set -e

OPTIONS="/data/options.json"

# 用 Python 从 /data/options.json 读取配置（xiaomusic 镜像自带 Python）
get_option() {
    python3 -c "import json,sys; d=json.load(open('${OPTIONS}')); v=d.get('$1',''); print(v if v is not None else '')" 2>/dev/null || echo ""
}

HOSTNAME=$(get_option 'XIAOMUSIC_HOSTNAME')
PORT=$(get_option 'XIAOMUSIC_PORT')
PUBLIC_PORT=$(get_option 'XIAOMUSIC_PUBLIC_PORT')
ACCOUNT=$(get_option 'XIAOMUSIC_ACCOUNT')
PASSWORD=$(get_option 'XIAOMUSIC_PASSWORD')
MI_DID=$(get_option 'XIAOMUSIC_MI_DID')
MUSIC_PATH=$(get_option 'XIAOMUSIC_MUSIC_PATH')
CONF_PATH=$(get_option 'XIAOMUSIC_CONF_PATH')
VERBOSE=$(get_option 'XIAOMUSIC_VERBOSE')

# 创建目录
mkdir -p "${MUSIC_PATH:-/share/xiaomusic/music}"
mkdir -p "${CONF_PATH:-/share/xiaomusic/conf}"

# 导出环境变量（有值才导出，避免空值或占位符干扰）
[[ -n "$PORT" && "$PORT" =~ ^[0-9]+$ ]]        && export XIAOMUSIC_PORT="$PORT"
[[ -n "$PUBLIC_PORT" && "$PUBLIC_PORT" =~ ^[0-9]+$ ]] && export XIAOMUSIC_PUBLIC_PORT="$PUBLIC_PORT"
[[ -n "$MUSIC_PATH" ]]  && export XIAOMUSIC_MUSIC_PATH="$MUSIC_PATH"
[[ -n "$CONF_PATH" ]]   && export XIAOMUSIC_CONF_PATH="$CONF_PATH"
[[ -n "$HOSTNAME" ]]    && export XIAOMUSIC_HOSTNAME="$HOSTNAME"
[[ -n "$ACCOUNT" ]]     && export XIAOMUSIC_ACCOUNT="$ACCOUNT"
[[ -n "$PASSWORD" ]]    && export XIAOMUSIC_PASSWORD="$PASSWORD"
[[ -n "$MI_DID" ]]      && export XIAOMUSIC_MI_DID="$MI_DID"
[[ "$VERBOSE" == "true" ]] && export XIAOMUSIC_VERBOSE="true"

echo "[Info] 启动 XiaoMusic..."
echo "[Info] PORT=${XIAOMUSIC_PORT} PUBLIC_PORT=${XIAOMUSIC_PUBLIC_PORT}"
echo "[Info] MUSIC_PATH=${XIAOMUSIC_MUSIC_PATH}"

exec xiaomusic
