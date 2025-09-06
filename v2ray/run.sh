#!/bin/bash
set -e

get_config(){
  key=$1
  default=$2
  [ -f /data/options.json ] && jq -r --arg key "$key" '.[$key]//"'$default'"' /data/options.json || echo "$default"
}

SUBSCRIPTION_URL=$(get_config "subscription_url" "")
LOG_LEVEL=$(get_config "log_level" "warning")
SOCKS_PORT=$(get_config "socks_port" 10808)
HTTP_PORT=$(get_config "http_port" 10809)
UPDATE_INTERVAL=$(get_config "update_interval" 24)
AUTO_START=$(get_config "auto_start" "true")
SELECTED_NODE=$(get_config "selected_node" -1)

mkdir -p /data/v2ray
CONFIG_FILE=/data/v2ray/config.json
SUB_FILE=/data/v2ray/subscription_config.json

update_subscription(){
  if [ -n "$SUBSCRIPTION_URL" ]; then
    echo "INFO: Downloading subscription..."
    curl -L -s -o /tmp/sub.txt "$SUBSCRIPTION_URL" || { echo "ERROR: download failed"; return 1; }
    python3 /app/parse_subscription.py /tmp/sub.txt "$SUB_FILE" "$SOCKS_PORT" "$HTTP_PORT" "$LOG_LEVEL" "$SELECTED_NODE" || return 1
    cp "$SUB_FILE" "$CONFIG_FILE"
    echo "INFO: V2Ray config updated from subscription"
    return 0
  fi
  return 1
}

create_default_config(){
  cat > "$CONFIG_FILE" << EOF
{
  "log": {"loglevel":"$LOG_LEVEL"},
  "inbounds":[
    {"port":$SOCKS_PORT,"protocol":"socks","settings":{"auth":"noauth","udp":true},"tag":"socks-in"},
    {"port":$HTTP_PORT,"protocol":"http","settings":{},"tag":"http-in"}
  ],
  "outbounds":[{"protocol":"freedom","settings":{},"tag":"direct"}]
}
EOF
}

if ! update_subscription; then
  [ -f "$CONFIG_FILE" ] || create_default_config
fi

if [ -n "$SUBSCRIPTION_URL" ] && [ "$AUTO_START" = "true" ]; then
(
  while true; do
    sleep $((UPDATE_INTERVAL*3600))
    echo "INFO: Updating subscription..."
    if update_subscription; then
      pkill v2ray 2>/dev/null || true
      sleep 2
    fi
  done
) &
fi

[ -f "$CONFIG_FILE" ] || { echo "ERROR: config not found"; exit 1; }
if ! /usr/bin/v2ray test -c "$CONFIG_FILE"; then
  echo "ERROR: invalid config"; exit 1
fi

exec /usr/bin/v2ray run -c "$CONFIG_FILE"
