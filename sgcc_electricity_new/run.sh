#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

# -------- 读取配置 --------
COMMAND="$(bashio::config 'command')"
ARGS=()
if bashio::config.has_value 'args'; then
  while IFS= read -r arg; do
    ARGS+=("${arg}")
  done < <(bashio::config 'args | .[]')
fi

export SGCC_PHONE="$(bashio::config 'phone')"
export SGCC_PASSWORD="$(bashio::config 'password')"
export SGCC_TOKEN="$(bashio::config 'token')"
export SGCC_COOKIE="$(bashio::config 'cookie')"
export SGCC_ACCOUNT_ID="$(bashio::config 'account_id')"
export SGCC_CITY_CODE="$(bashio::config 'city_code')"
export SGCC_POLL_INTERVAL="$(bashio::config 'poll_interval')"
export SGCC_HTTP_PORT="$(bashio::config 'http_port')"
export LOG_LEVEL="$(bashio::config 'log_level')"

# 追加自定义环境变量
if bashio::config.has_value 'extra_env'; then
  while IFS='=' read -r key value; do
    if [[ -n "$key" ]]; then
      export "$key"="$value"
    fi
  done < <(bashio::config 'extra_env | to_entries | .[] | "\(.key)=\(.value)"')
fi

bashio::log.info "Starting sgcc_electricity_new with command: ${COMMAND} ${ARGS[*]:-}"

cd /opt/app

# 若项目需要写配置文件到 /data，可在此生成（示例）：
# cat > /data/config.json <<EOF
# {"phone": "${SGCC_PHONE}", "password": "${SGCC_PASSWORD}", "account_id": "${SGCC_ACCOUNT_ID}", "city_code": "${SGCC_CITY_CODE}", "poll_interval": ${SGCC_POLL_INTERVAL}}
# EOF

# 如果项目有 HTTP/UVicorn 等，可这样启动（示例，按需替换）：
# if [ -f app.py ]; then
#   exec python3 -m uvicorn app:app --host 0.0.0.0 --port "${SGCC_HTTP_PORT}"
# fi

# 默认执行用户指定命令
exec ${COMMAND} "${ARGS[@]}"