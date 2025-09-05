#!/usr/bin/with-contenv bashio

# Parse configuration
CONFIG_FILE=$(bashio::config 'config_file')
LOG_LEVEL=$(bashio::config 'log_level')

# Create config directory if it doesn't exist
mkdir -p /config/v2ray

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    bashio::log.warning "Config file not found at $CONFIG_FILE"
    bashio::log.info "Creating default config file..."
    
    # Create a basic config template
    cat > "$CONFIG_FILE" << EOF
{
    "log": {
        "loglevel": "$LOG_LEVEL"
    },
    "inbounds": [
        {
            "port": 10808,
            "protocol": "socks",
            "settings": {
                "auth": "noauth",
                "udp": true
            }
        },
        {
            "port": 10809,
            "protocol": "http"
        }
    ],
    "outbounds": [
        {
            "protocol": "direct",
            "settings": {}
        }
    ]
}
EOF
    bashio::log.info "Default config created. Please edit $CONFIG_FILE and restart the add-on."
fi

# Start V2Ray
bashio::log.info "Starting V2Ray with config: $CONFIG_FILE"
bashio::log.info "Log level: $LOG_LEVEL"

# Run v2ray with the specified config
exec v2ray run -config "$CONFIG_FILE"