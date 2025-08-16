#!/usr/bin/with-contenv bashio

# 获取配置选项
CONFIG_PATH=$(bashio::config 'config_file')
LOG_LEVEL=$(bashio::config 'log_level')

# 检查配置文件是否存在
if [[ ! -f "$CONFIG_PATH" ]]; then
    bashio::log.error "Configuration file not found: $CONFIG_PATH"
    bashio::log.info "Creating default configuration file..."
    
    # 创建默认配置
    cat > "$CONFIG_PATH" << 'EOF'
{
  "log": {
    "loglevel": "warning"
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
      "protocol": "http",
      "settings": {}
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF
    bashio::log.info "Default configuration created at $CONFIG_PATH"
fi

# 更新日志级别
if [[ -n "$LOG_LEVEL" ]]; then
    bashio::log.info "Setting log level to: $LOG_LEVEL"
    jq --arg level "$LOG_LEVEL" '.log.loglevel = $level' "$CONFIG_PATH" > "$CONFIG_PATH.tmp" && mv "$CONFIG_PATH.tmp" "$CONFIG_PATH"
fi

# 验证配置文件
bashio::log.info "Validating configuration..."
if ! xray -test -config "$CONFIG_PATH"; then
    bashio::log.error "Invalid configuration file!"
    exit 1
fi

bashio::log.info "Starting XRay..."
bashio::log.info "Configuration file: $CONFIG_PATH"
bashio::log.info "Log level: $LOG_LEVEL"

# 启动XRay
exec xray -config "$CONFIG_PATH"