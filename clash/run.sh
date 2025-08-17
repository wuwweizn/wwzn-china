#!/usr/bin/with-contenv bashio

# 获取配置选项
LOG_LEVEL=$(bashio::config 'log_level')
EXTERNAL_CONTROLLER=$(bashio::config 'external_controller')
SECRET=$(bashio::config 'secret')

CONFIG_PATH="/data/config/config.yaml"

# 确保配置目录存在
mkdir -p /data/config
mkdir -p /data/logs

# 创建一个干净的配置文件（一次性创建，避免重复）
create_clean_config() {
    bashio::log.info "Creating clean Clash configuration..."
    
    cat > "$CONFIG_PATH" << EOF
port: 7890
socks-port: 7891
allow-lan: true
bind-address: '*'
mode: rule
log-level: ${LOG_LEVEL:-info}
external-controller: ${EXTERNAL_CONTROLLER:-0.0.0.0:9090}
external-ui: ui

dns:
  enable: true
  listen: 0.0.0.0:1053
  ipv6: false
  default-nameserver:
    - 119.29.29.29
    - 223.5.5.5
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  nameserver:
    - https://doh.pub/dns-query
    - https://dns.alidns.com/dns-query

proxies:
  - name: "DIRECT"
    type: direct

proxy-groups:
  - name: "🚀 代理选择"
    type: select
    proxies:
      - DIRECT
  
  - name: "🎯 全球直连"
    type: select
    proxies:
      - DIRECT
  
  - name: "🐟 漏网之鱼"
    type: select
    proxies:
      - "🚀 代理选择"
      - DIRECT

rules:
  - IP-CIDR,192.168.0.0/16,🎯 全球直连
  - IP-CIDR,10.0.0.0/8,🎯 全球直连
  - IP-CIDR,172.16.0.0/12,🎯 全球直连
  - IP-CIDR,127.0.0.0/8,🎯 全球直连
  - GEOIP,LAN,🎯 全球直连
  - GEOIP,CN,🎯 全球直连
  - MATCH,🐟 漏网之鱼
EOF

    # 添加密钥（如果设置）
    if [[ -n "$SECRET" ]]; then
        echo "secret: '$SECRET'" >> "$CONFIG_PATH"
    fi
    
    bashio::log.info "Clean configuration created successfully"
}

# 只创建一次配置，避免重复调用
if [[ ! -f "$CONFIG_PATH" ]]; then
    create_clean_config
else
    bashio::log.info "Configuration file already exists, using existing one"
fi

# 验证配置文件
bashio::log.info "Validating Clash configuration..."
if clash -t -f "$CONFIG_PATH" -d /opt/clash; then
    bashio::log.info "Configuration validation passed!"
else
    bashio::log.error "Configuration validation failed, recreating..."
    rm -f "$CONFIG_PATH"
    create_clean_config
    
    # 最后一次验证
    if ! clash -t -f "$CONFIG_PATH" -d /opt/clash; then
        bashio::log.error "Still failed! Showing config content for debug:"
        cat "$CONFIG_PATH"
        exit 1
    fi
fi

# 显示启动信息
bashio::log.info "=== Clash Starting ==="
bashio::log.info "Config: $CONFIG_PATH"
bashio::log.info "Log Level: ${LOG_LEVEL:-info}"
bashio::log.info "Controller: ${EXTERNAL_CONTROLLER:-0.0.0.0:9090}"
bashio::log.info "Web UI: http://192.168.2.85:9090/ui"

if [[ -n "$SECRET" ]]; then
    bashio::log.info "Secret: Configured"
fi

# 启动Clash
bashio::log.info "Starting Clash service..."
exec clash -f "$CONFIG_PATH" -d /opt/clash