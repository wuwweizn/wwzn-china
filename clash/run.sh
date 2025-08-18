#!/usr/bin/with-contenv bashio

# 获取配置选项
LOG_LEVEL=$(bashio::config 'log_level')
EXTERNAL_CONTROLLER=$(bashio::config 'external_controller')
SECRET=$(bashio::config 'secret')
SUBSCRIPTION_URL=$(bashio::config 'subscription_url')
AUTO_UPDATE=$(bashio::config 'auto_update_subscription')
UPDATE_INTERVAL=$(bashio::config 'update_interval')
USER_AGENT=$(bashio::config 'subscription_user_agent')
CUSTOM_CONFIG=$(bashio::config 'custom_config')

CONFIG_PATH="/data/config/config.yaml"

# 确保配置目录存在
mkdir -p /data/config
mkdir -p /data/logs

bashio::log.info "=== Clash Meta Configuration Manager ==="

# 创建基础配置模板
create_base_config() {
    bashio::log.info "Creating base configuration template..."
    
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
  fallback:
    - https://cloudflare-dns.com/dns-query
    - https://dns.google/dns-query

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

    # 添加密钥
    if [[ -n "$SECRET" ]]; then
        echo "secret: '$SECRET'" >> "$CONFIG_PATH"
    fi
    
    bashio::log.info "Base configuration created"
}

# 处理自定义配置
process_custom_config() {
    if [[ -n "$CUSTOM_CONFIG" ]]; then
        bashio::log.info "Processing custom configuration..."
        
        # 检查是否是完整的YAML配置
        if [[ "$CUSTOM_CONFIG" =~ ^(port:|mixed-port:|proxies:|proxy-groups:) ]]; then
            bashio::log.info "Using complete custom configuration"
            echo "$CUSTOM_CONFIG" > "$CONFIG_PATH"
            
            # 确保管理API配置存在
            if ! grep -q "external-controller:" "$CONFIG_PATH"; then
                echo "external-controller: ${EXTERNAL_CONTROLLER:-0.0.0.0:9090}" >> "$CONFIG_PATH"
            fi
            if ! grep -q "external-ui:" "$CONFIG_PATH"; then
                echo "external-ui: ui" >> "$CONFIG_PATH"
            fi
            if [[ -n "$SECRET" ]] && ! grep -q "secret:" "$CONFIG_PATH"; then
                echo "secret: '$SECRET'" >> "$CONFIG_PATH"
            fi
            
            return 0
        else
            bashio::log.warning "Custom config format not recognized, falling back to subscription"
        fi
    fi
    return 1
}

# 下载并处理订阅
download_subscription() {
    local url="$1"
    local temp_file="/tmp/subscription_raw.txt"
    
    bashio::log.info "Downloading subscription from: $url"
    
    # 设置User-Agent
    local curl_opts=("-f" "-s" "--max-time" "30")
    if [[ -n "$USER_AGENT" ]]; then
        curl_opts+=("-H" "User-Agent: $USER_AGENT")
    fi
    
    if curl "${curl_opts[@]}" -o "$temp_file" "$url"; then
        cat "$temp_file"
        return 0
    else
        bashio::log.error "Failed to download subscription"
        return 1
    fi
}

# 智能转换订阅
convert_subscription() {
    local raw_content="$1"
    
    bashio::log.info "Processing subscription content..."
    
    # 检查是否已经是Clash格式
    if [[ "$raw_content" =~ ^(port:|mixed-port:|proxies:|proxy-groups:) ]]; then
        bashio::log.info "Content is already in Clash format"
        echo "$raw_content" > "$CONFIG_PATH"
        return 0
    fi
    
    # 检查是否是Base64编码
    local decoded_content="$raw_content"
    if [[ "$raw_content" =~ ^[A-Za-z0-9+/]*={0,2}$ ]] && [[ ${#raw_content} -gt 100 ]]; then
        bashio::log.info "Decoding Base64 content..."
        decoded_content=$(echo "$raw_content" | base64 -d 2>/dev/null || echo "$raw_content")
    fi
    
    # 检查是否包含代理链接
    if [[ "$decoded_content" =~ (ss://|ssr://|vmess://|trojan://|vless://|hysteria://|tuic://) ]]; then
        bashio::log.info "Found proxy links, attempting conversion..."
        
        # 尝试多个转换服务
        local converters=(
            "https://api.dler.io/sub?target=clash&url="
            "https://sub.xeton.dev/sub?target=clash&url="
            "https://api.v1.mk/sub?target=clash&url="
        )
        
        # URL编码订阅链接
        local encoded_url=$(printf '%s' "$SUBSCRIPTION_URL" | jq -sRr @uri)
        
        for converter in "${converters[@]}"; do
            bashio::log.info "Trying converter: ${converter%?target=*}"
            if curl -f -s --max-time 20 -o "$CONFIG_PATH" "${converter}${encoded_url}"; then
                bashio::log.info "Conversion successful"
                return 0
            fi
        done
        
        bashio::log.warning "All converters failed, creating manual configuration"
        create_manual_config "$decoded_content"
        return 0
    fi
    
    bashio::log.warning "Unknown subscription format"
    return 1
}

# 手动创建配置（当转换失败时）
create_manual_config() {
    local proxy_links="$1"
    
    bashio::log.info "Creating manual configuration from proxy links..."
    
    # 创建基础配置
    create_base_config
    
    # 添加提示信息
    cat >> "$CONFIG_PATH" << 'EOF'

# 注意：自动转换失败，请手动配置节点
# 您的订阅包含以下代理链接：
# 请使用Clash客户端或在线工具转换后手动替换此配置

# 代理链接列表：
EOF
    
    # 将代理链接作为注释添加
    echo "$proxy_links" | while IFS= read -r line; do
        if [[ "$line" =~ ^(ss://|ssr://|vmess://|trojan://|vless://) ]]; then
            echo "# $line" >> "$CONFIG_PATH"
        fi
    done
}

# 更新管理配置
update_management_config() {
    bashio::log.info "Updating management configuration..."
    
    # 更新external-controller
    if grep -q "external-controller:" "$CONFIG_PATH"; then
        sed -i "s/external-controller: .*/external-controller: ${EXTERNAL_CONTROLLER:-0.0.0.0:9090}/" "$CONFIG_PATH"
    else
        echo "external-controller: ${EXTERNAL_CONTROLLER:-0.0.0.0:9090}" >> "$CONFIG_PATH"
    fi
    
    # 更新external-ui
    if ! grep -q "external-ui:" "$CONFIG_PATH"; then
        echo "external-ui: ui" >> "$CONFIG_PATH"
    fi
    
    # 更新secret
    if [[ -n "$SECRET" ]]; then
        if grep -q "secret:" "$CONFIG_PATH"; then
            sed -i "s/secret: .*/secret: '$SECRET'/" "$CONFIG_PATH"
        else
            echo "secret: '$SECRET'" >> "$CONFIG_PATH"
        fi
    fi
}

# 定时更新订阅
schedule_subscription_update() {
    if [[ "$AUTO_UPDATE" == "true" ]] && [[ -n "$SUBSCRIPTION_URL" ]]; then
        bashio::log.info "Scheduling automatic subscription updates every $UPDATE_INTERVAL seconds"
        
        (
            while true; do
                sleep "$UPDATE_INTERVAL"
                bashio::log.info "Auto-updating subscription..."
                
                if process_subscription; then
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

# 处理订阅的主函数
process_subscription() {
    if [[ -n "$SUBSCRIPTION_URL" ]]; then
        bashio::log.info "Processing subscription URL..."
        
        if raw_content=$(download_subscription "$SUBSCRIPTION_URL"); then
            if convert_subscription "$raw_content"; then
                update_management_config
                return 0
            fi
        fi
        
        bashio::log.warning "Subscription processing failed"
        return 1
    fi
    return 1
}

# 主配置流程
bashio::log.info "Starting configuration process..."

# 1. 优先处理自定义配置
if process_custom_config; then
    bashio::log.info "Using custom configuration"
    
# 2. 处理订阅URL
elif process_subscription; then
    bashio::log.info "Using subscription configuration"
    
# 3. 使用现有配置或创建默认配置
elif [[ -f "$CONFIG_PATH" ]]; then
    bashio::log.info "Using existing configuration file"
    update_management_config
else
    bashio::log.info "Creating default configuration"
    create_base_config
fi

# 验证配置
bashio::log.info "Validating configuration..."
if clash -t -f "$CONFIG_PATH" -d /opt/clash; then
    bashio::log.info "✅ Configuration validation passed!"
else
    bashio::log.error "❌ Configuration validation failed!"
    bashio::log.info "Creating fallback configuration..."
    create_base_config
    
    if ! clash -t -f "$CONFIG_PATH" -d /opt/clash; then
        bashio::log.error "❌ Fallback configuration also failed!"
        exit 1
    fi
fi

# 启动定时更新
schedule_subscription_update

# 显示配置信息
bashio::log.info "=== Clash Meta Ready ==="
bashio::log.info "📁 Config: $CONFIG_PATH"
bashio::log.info "📊 Log Level: ${LOG_LEVEL:-info}"
bashio::log.info "🌐 Controller: ${EXTERNAL_CONTROLLER:-0.0.0.0:9090}"
bashio::log.info "🎨 Web UI: http://192.168.2.85:9090/ui"

if [[ -n "$SECRET" ]]; then
    bashio::log.info "🔐 Secret: Configured"
fi

if [[ -n "$SUBSCRIPTION_URL" ]]; then
    bashio::log.info "📡 Subscription: Configured"
    bashio::log.info "🔄 Auto Update: $AUTO_UPDATE"
fi

# 启动Clash
bashio::log.info "🚀 Starting Clash service..."
exec clash -f "$CONFIG_PATH" -d /opt/clash