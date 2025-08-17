#!/usr/bin/with-contenv bashio

# 获取配置选项
LOG_LEVEL=$(bashio::config 'log_level')
EXTERNAL_CONTROLLER=$(bashio::config 'external_controller')
SECRET=$(bashio::config 'secret')
SUBSCRIPTION_URL=$(bashio::config 'subscription_url')
UPDATE_INTERVAL=$(bashio::config 'update_interval')
AUTO_UPDATE=$(bashio::config 'auto_update')

CONFIG_PATH="/data/config/config.yaml"

# 确保配置目录存在
mkdir -p /data/config
mkdir -p /data/logs

# 创建默认配置文件
create_default_config() {
    bashio::log.info "Creating default Clash configuration..."
    
    # 确保目标目录存在
    mkdir -p "$(dirname "$CONFIG_PATH")"
    
    # 创建一个简化的默认配置
    cat > "$CONFIG_PATH" << 'EOF'
port: 7890
socks-port: 7891
allow-lan: true
bind-address: '*'
mode: rule
log-level: info
external-controller: 0.0.0.0:9090
external-ui: /opt/clash-dashboard

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
  - name: "REJECT"
    type: reject

proxy-groups:
  - name: "🚀 手动切换"
    type: select
    proxies:
      - DIRECT
      - REJECT
  
  - name: "🎯 全球直连"
    type: select
    proxies:
      - DIRECT
  
  - name: "🛑 广告拦截"
    type: select
    proxies:
      - REJECT
      - DIRECT
  
  - name: "🐟 漏网之鱼"
    type: select
    proxies:
      - "🚀 手动切换"
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
    
    # 更新配置文件中的选项
    if [[ -n "$LOG_LEVEL" ]]; then
        sed -i "s/log-level: info/log-level: $LOG_LEVEL/" "$CONFIG_PATH"
    fi
    
    if [[ -n "$EXTERNAL_CONTROLLER" ]]; then
        sed -i "s/external-controller: 0.0.0.0:9090/external-controller: $EXTERNAL_CONTROLLER/" "$CONFIG_PATH"
    fi
    
    if [[ -n "$SECRET" ]]; then
        echo "secret: '$SECRET'" >> "$CONFIG_PATH"
    fi
    
    bashio::log.info "Default configuration created at $CONFIG_PATH"
}

# 检查内容是否为Base64编码
is_base64() {
    local content="$1"
    # 检查是否包含Base64字符和长度
    if [[ "$content" =~ ^[A-Za-z0-9+/]*={0,2}$ ]] && [[ ${#content} -gt 100 ]]; then
        return 0
    else
        return 1
    fi
}

# 转换订阅格式
convert_subscription() {
    local raw_content="$1"
    local temp_file="/tmp/converted_subscription.yaml"
    
    bashio::log.info "Converting subscription format..."
    
    # 如果是Base64编码，先解码
    if is_base64 "$raw_content"; then
        bashio::log.info "Detected Base64 encoded subscription, decoding..."
        raw_content=$(echo "$raw_content" | base64 -d)
    fi
    
    # 检查解码后的内容
    if [[ "$raw_content" =~ ^(ss://|ssr://|vmess://|trojan://) ]]; then
        bashio::log.info "Detected proxy links, using subscription converter..."
        
        # 使用订阅转换服务
        local convert_url="https://api.dler.io/sub?target=clash&url="
        local encoded_links=$(echo "$raw_content" | tr '\n' '|' | sed 's/|$//' | jq -sRr @uri)
        
        if curl -f -o "$temp_file" "${convert_url}${encoded_links}"; then
            bashio::log.info "Successfully converted subscription"
            return 0
        else
            bashio::log.warning "Subscription conversion failed"
            return 1
        fi
    elif [[ "$raw_content" =~ ^(port:|mixed-port:|proxies:) ]]; then
        bashio::log.info "Detected Clash YAML format"
        echo "$raw_content" > "$temp_file"
        return 0
    else
        bashio::log.warning "Unknown subscription format"
        return 1
    fi
}

# 更新订阅
update_subscription() {
    if [[ -n "$SUBSCRIPTION_URL" ]]; then
        bashio::log.info "Updating subscription from: $SUBSCRIPTION_URL"
        
        # 下载订阅内容
        local raw_content
        if raw_content=$(curl -f -s "$SUBSCRIPTION_URL"); then
            bashio::log.info "Successfully downloaded subscription"
            
            # 转换格式
            if convert_subscription "$raw_content"; then
                # 备份当前配置
                if [[ -f "$CONFIG_PATH" ]]; then
                    cp "$CONFIG_PATH" "${CONFIG_PATH}.backup"
                fi
                
                # 使用转换后的配置
                mv "/tmp/converted_subscription.yaml" "$CONFIG_PATH"
                
                # 添加管理配置
                if ! grep -q "external-controller:" "$CONFIG_PATH"; then
                    echo "" >> "$CONFIG_PATH"
                    echo "external-controller: $EXTERNAL_CONTROLLER" >> "$CONFIG_PATH"
                    echo "external-ui: /opt/clash-dashboard" >> "$CONFIG_PATH"
                else
                    sed -i "s/external-controller: .*/external-controller: $EXTERNAL_CONTROLLER/" "$CONFIG_PATH"
                fi
                
                if [[ -n "$SECRET" ]]; then
                    if grep -q "secret:" "$CONFIG_PATH"; then
                        sed -i "s/secret: .*/secret: '$SECRET'/" "$CONFIG_PATH"
                    else
                        echo "secret: '$SECRET'" >> "$CONFIG_PATH"
                    fi
                fi
                
                bashio::log.info "Subscription updated successfully"
                return 0
            else
                bashio::log.warning "Failed to convert subscription format"
                return 1
            fi
        else
            bashio::log.warning "Failed to download subscription"
            return 1
        fi
    fi
}

# 定时更新订阅
schedule_updates() {
    if [[ "$AUTO_UPDATE" == "true" ]] && [[ -n "$SUBSCRIPTION_URL" ]]; then
        bashio::log.info "Scheduling automatic subscription updates every $UPDATE_INTERVAL seconds"
        
        (
            while true; do
                sleep "$UPDATE_INTERVAL"
                bashio::log.info "Auto-updating subscription..."
                if update_subscription; then
                    # 重新加载配置
                    if pgrep clash > /dev/null; then
                        pkill -HUP clash
                        bashio::log.info "Configuration reloaded"
                    fi
                fi
            done
        ) &
    fi
}

# 检查并创建配置文件
if [[ ! -f "$CONFIG_PATH" ]]; then
    create_default_config
fi

# 尝试更新订阅（如果配置了）
if [[ -n "$SUBSCRIPTION_URL" ]]; then
    if ! update_subscription; then
        bashio::log.warning "Subscription update failed, using default config"
        create_default_config
    fi
fi

# 验证配置文件
bashio::log.info "Validating Clash configuration..."
if ! clash -t -f "$CONFIG_PATH" -d /opt/clash; then
    bashio::log.error "Configuration validation failed!"
    bashio::log.info "Creating new default configuration..."
    create_default_config
    
    # 再次验证
    if ! clash -t -f "$CONFIG_PATH" -d /opt/clash; then
        bashio::log.error "Default configuration validation failed!"
        exit 1
    fi
fi

# 启动定时更新（如果启用）
schedule_updates

# 显示启动信息
bashio::log.info "Starting Clash..."
bashio::log.info "Configuration file: $CONFIG_PATH"
bashio::log.info "Log level: $LOG_LEVEL"
bashio::log.info "External controller: $EXTERNAL_CONTROLLER"
bashio::log.info "Web dashboard: http://192.168.2.85:9090/ui"

if [[ -n "$SUBSCRIPTION_URL" ]]; then
    bashio::log.info "Subscription URL configured"
    bashio::log.info "Auto update: $AUTO_UPDATE"
fi

# 启动Clash
exec clash -f "$CONFIG_PATH" -d /opt/clash