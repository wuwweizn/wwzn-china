#!/usr/bin/with-contenv bashio

# Parse configuration
SUBSCRIPTION_URL=$(bashio::config 'subscription_url')
LOG_LEVEL=$(bashio::config 'log_level')
SOCKS_PORT=$(bashio::config 'socks_port')
HTTP_PORT=$(bashio::config 'http_port')
UPDATE_INTERVAL=$(bashio::config 'update_interval')
AUTO_START=$(bashio::config 'auto_start')

# Create config directory
mkdir -p /config/v2ray

CONFIG_FILE="/config/v2ray/config.json"
SUBSCRIPTION_FILE="/config/v2ray/subscription_config.json"

# Function to download and parse subscription
update_subscription() {
    if [ -n "$SUBSCRIPTION_URL" ]; then
        bashio::log.info "Downloading subscription from: $SUBSCRIPTION_URL"
        
        # Download subscription content
        if curl -L -s -o /tmp/subscription.txt "$SUBSCRIPTION_URL"; then
            bashio::log.info "Subscription downloaded successfully"
            
            # Decode base64 if needed
            if base64 -d /tmp/subscription.txt > /tmp/decoded.txt 2>/dev/null; then
                mv /tmp/decoded.txt /tmp/subscription.txt
                bashio::log.info "Base64 decoded subscription"
            fi
            
            # Parse subscription and generate V2Ray config
            python3 /parse_subscription.py /tmp/subscription.txt "$SUBSCRIPTION_FILE" "$SOCKS_PORT" "$HTTP_PORT" "$LOG_LEVEL"
            
            if [ -f "$SUBSCRIPTION_FILE" ]; then
                cp "$SUBSCRIPTION_FILE" "$CONFIG_FILE"
                bashio::log.info "V2Ray config updated from subscription"
                return 0
            else
                bashio::log.error "Failed to parse subscription"
                return 1
            fi
        else
            bashio::log.error "Failed to download subscription"
            return 1
        fi
    else
        bashio::log.warning "No subscription URL provided"
        return 1
    fi
}

# Function to create default config
create_default_config() {
    bashio::log.info "Creating default V2Ray config"
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
            "protocol": "direct",
            "settings": {},
            "tag": "direct"
        }
    ],
    "routing": {
        "rules": [
            {
                "type": "field",
                "outboundTag": "direct",
                "protocol": ["bittorrent"]
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
            bashio::log.info "Updating subscription (interval: ${UPDATE_INTERVAL}h)"
            if update_subscription; then
                bashio::log.info "Subscription updated, restarting V2Ray"
                pkill v2ray 2>/dev/null || true
                sleep 2
            fi
        done
    ) &
fi

# Validate config file
if [ ! -f "$CONFIG_FILE" ]; then
    bashio::log.error "Config file not found: $CONFIG_FILE"
    exit 1
fi

if ! v2ray test -config "$CONFIG_FILE"; then
    bashio::log.error "Invalid V2Ray configuration"
    exit 1
fi

# Start V2Ray
bashio::log.info "Starting V2Ray..."
bashio::log.info "SOCKS5 proxy: localhost:$SOCKS_PORT"
bashio::log.info "HTTP proxy: localhost:$HTTP_PORT"
bashio::log.info "Log level: $LOG_LEVEL"

if [ -n "$SUBSCRIPTION_URL" ]; then
    bashio::log.info "Subscription URL configured"
    bashio::log.info "Auto update interval: ${UPDATE_INTERVAL} hours"
fi

# Run v2ray
exec v2ray run -c "$CONFIG_FILE"