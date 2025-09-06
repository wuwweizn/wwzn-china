#!/bin/bash
set -e

get_config() {
    local key=$1
    local default_value=$2
    if [ -f "/data/options.json" ]; then
        jq -r --arg key "$key" --arg default "$default_value" '.[$key] // $default' /data/options.json
    else
        echo "$default_value"
    fi
}

SUBSCRIPTION_URL=$(get_config "subscription_url" "")
LOG_LEVEL=$(get_config "log_level" "warning")
SOCKS_PORT=$(get_config "socks_port" "10808")
HTTP_PORT=$(get_config "http_port" "10809")
UPDATE_INTERVAL=$(get_config "update_interval" "24")
AUTO_START=$(get_config "auto_start" "true")
SELECTED_NODE=$(get_config "selected_node" "0")
ENABLE_NODE_SELECTION=$(get_config "enable_node_selection" "true")

mkdir -p /data/v2ray
CONFIG_FILE="/data/v2ray/config.json"
SUBSCRIPTION_FILE="/data/v2ray/subscription_config.json"

update_subscription() {
    if [ -n "$SUBSCRIPTION_URL" ]; then
        echo "INFO: Downloading subscription..."
        if curl -L -s -o /tmp/subscription.txt "$SUBSCRIPTION_URL"; then
            if base64 -d /tmp/subscription.txt > /tmp/decoded.txt 2>/dev/null; then
                mv /tmp/decoded.txt /tmp/subscription.txt
            fi
            python3 /app/parse_subscription.py /tmp/subscription.txt "$SUBSCRIPTION_FILE" "$SOCKS_PORT" "$HTTP_PORT" "$LOG_LEVEL" "$SELECTED_NODE" "$ENABLE_NODE_SELECTION"
            cp "$SUBSCRIPTION_FILE" "$CONFIG_FILE"
            return 0
        fi
    fi
    return 1
}

create_default_config() {
    cat > "$CONFIG_FILE" << EOF
{
    "log": {"loglevel": "$LOG_LEVEL"},
    "inbounds": [
        {"port": $SOCKS_PORT,"protocol": "socks","settings":{"auth":"noauth","udp":true},"tag":"socks-in"},
        {"port": $HTTP_PORT,"protocol": "http","settings":{},"tag":"http-in"}
    ],
    "outbounds":[{"protocol":"freedom","settings":{},"tag":"direct"}],
    "routing":{"domainStrategy":"IPIfNonMatch","rules":[]}
}
EOF
}

if ! update_subscription && [ ! -f "$CONFIG_FILE" ]; then
    create_default_config
fi

if [ -n "$SUBSCRIPTION_URL" ] && [ "$AUTO_START" = "true" ]; then
    (while true; do
        sleep $((UPDATE_INTERVAL*3600))
        update_subscription
    done) &
fi

exec /usr/bin/v2ray run -c "$CONFIG_FILE"
