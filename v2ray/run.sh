#!/bin/bash
set -e

# Function to get config value from options.json
get_config() {
    local key=$1
    local default_value=$2
    if [ -f "/data/options.json" ]; then
        jq -r --arg key "$key" --arg default "$default_value" '.[$key] // $default' /data/options.json
    else
        echo "$default_value"
    fi
}

# Parse configuration from Home Assistant
SUBSCRIPTION_URL=$(get_config "subscription_url" "")
LOG_LEVEL=$(get_config "log_level" "warning")
SOCKS_PORT=$(get_config "socks_port" "10808")
HTTP_PORT=$(get_config "http_port" "10809")
UPDATE_INTERVAL=$(get_config "update_interval" "24")
AUTO_START=$(get_config "auto_start" "true")

echo "INFO: Starting V2Ray Add-on"
echo "INFO: Log level: $LOG_LEVEL"
echo "INFO: SOCKS port: $SOCKS_PORT"
echo "INFO: HTTP port: $HTTP_PORT"

# Create config directory
mkdir -p /data/v2ray

CONFIG_FILE="/data/v2ray/config.json"
SUBSCRIPTION_FILE="/data/v2ray/subscription_config.json"

# Function to download and parse subscription
update_subscription() {
    if [ -n "$SUBSCRIPTION_URL" ]; then
        echo "INFO: Downloading subscription from: $SUBSCRIPTION_URL"
        
        # Download subscription content
        if curl -L -s -o /tmp/subscription.txt "$SUBSCRIPTION_URL"; then
            echo "INFO: Subscription downloaded successfully"
            
            # Decode base64 if needed
            if base64 -d /tmp/subscription.txt > /tmp/decoded.txt 2>/dev/null; then
                mv /tmp/decoded.txt /tmp/subscription.txt
                echo "INFO: Base64 decoded subscription"
            fi
            
            # Parse subscription and generate V2Ray config
            python3 /app/parse_subscription.py /tmp/subscription.txt "$SUBSCRIPTION_FILE" "$SOCKS_PORT" "$HTTP_PORT" "$LOG_LEVEL"
            
            if [ -f "$SUBSCRIPTION_FILE" ]; then
                cp "$SUBSCRIPTION_FILE" "$CONFIG_FILE"
                echo "INFO: V2Ray config updated from subscription"
                return 0
            else
                echo "ERROR: Failed to parse subscription"
                return 1
            fi
        else
            echo "ERROR: Failed to download subscription"
            return 1
        fi
    else
        echo "WARNING: No subscription URL provided"
        return 1
    fi
}

# Function to create default config
create_default_config() {
    echo "INFO: Creating default V2Ray config"
    cat > "$CONFIG_FILE" << EOF
{
    "log": {
        "loglevel": "$LOG_LEVEL"
    },
    "inbounds": [
        {
            "port": $SOCKS_PORT,
            "protocol": "socks",
            "settings": {
                "auth": "noauth",
                "udp": true
            },
            "tag": "socks-in"
        },
        {
            "port": $HTTP_PORT,
            "protocol": "http",
            "settings": {},
            "tag": "http-in"
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "settings": {},
            "tag": "direct"
        }
    ],
    "routing": {
        "domainStrategy": "IPIfNonMatch",
        "rules": [
            {
                "type": "field",
                "outboundTag": "direct",
                "network": "tcp,udp"
            }
        ]
    }
}
EOF
}

# Update subscription or create default config
if ! update_subscription; then
    if [ ! -f "$CONFIG_FILE" ]; then
        create_default_config
    fi
fi

# Set up periodic subscription update
if [ -n "$SUBSCRIPTION_URL" ] && [ "$AUTO_START" = "true" ]; then
    (
        while true; do
            sleep $((UPDATE_INTERVAL * 3600))
            echo "INFO: Updating subscription (interval: ${UPDATE_INTERVAL}h)"
            if update_subscription; then
                echo "INFO: Subscription updated, restarting V2Ray"
                pkill v2ray 2>/dev/null || true
                sleep 2
            fi
        done
    ) &
fi

# Validate config file
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Config file not found: $CONFIG_FILE"
    exit 1
fi

if ! /usr/bin/v2ray test -c "$CONFIG_FILE"; then
    echo "ERROR: Invalid V2Ray configuration"
    exit 1
fi

# Start V2Ray
echo "INFO: Starting V2Ray..."
echo "INFO: SOCKS5 proxy: localhost:$SOCKS_PORT"
echo "INFO: HTTP proxy: localhost:$HTTP_PORT"
echo "INFO: Log level: $LOG_LEVEL"

if [ -n "$SUBSCRIPTION_URL" ]; then
    echo "INFO: Subscription URL configured"
    echo "INFO: Auto update interval: ${UPDATE_INTERVAL} hours"
fi

# Run v2ray
exec /usr/bin/v2ray run -c "$CONFIG_FILE"