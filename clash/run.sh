#!/usr/bin/with-contenv bashio

# 获取配置选项
LOG_LEVEL=$(bashio::config 'log_level')
EXTERNAL_CONTROLLER=$(bashio::config 'external_controller')
SECRET=$(bashio::config 'secret')
SUBSCRIPTION_URL=$(bashio::config 'subscription_url')
UPDATE_INTERVAL=$(bashio::config 'update_interval')
AUTO_UPDATE=$(bashio::config 'auto_update')

CONFIG_PATH="/data/config/config.yaml"

# 创建默认配置文件
create_default_config() {
    bashio::log.info "Creating default Clash configuration..."
    cp /opt/clash/default-config.yaml "$CONFIG_PATH"
    
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

# 更新订阅
update_subscription() {
    if [[ -n "$SUBSCRIPTION_URL" ]]; then
        bashio::log.info "Updating subscription from: $SUBSCRIPTION_URL"
        
        # 下载订阅配置
        if curl -L -o "/tmp/subscription.yaml" "$SUBSCRIPTION_URL"; then
            bashio::log.info "Successfully downloaded subscription config"
            
            # 备份当前配置
            if [[ -f "$CONFIG_PATH" ]]; then
                cp "$CONFIG_PATH" "${CONFIG_PATH}.backup"
            fi
            
            # 使用订阅配置
            mv "/tmp/subscription.yaml" "$CONFIG_PATH"
            
            # 更新配置文件中的管理选项
            if ! grep -q "external-controller:" "$CONFIG_PATH"; then
                echo "" >> "$CONFIG_PATH"
                echo "# Management API" >> "$CONFIG_PATH"
                echo "external-controller: $EXTERNAL_CONTROLLER" >> "$CONFIG_PATH"
                echo "external-ui: /opt/clash-dashboard" >> "$CONFIG_PATH"
            fi
            
            if [[ -n "$SECRET" ]] && ! grep -q "secret:" "$CONFIG_PATH"; then
                echo "secret: '$SECRET'" >> "$CONFIG_PATH"
            fi
            
            bashio::log.info "Subscription updated successfully"
        else
            bashio::log.warning "Failed to download subscription, using existing config"
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
                update_subscription
                
                # 重新加载配置（向clash发送HUP信号）
                if pgrep clash > /dev/null; then
                    pkill -HUP clash
                    bashio::log.info "Configuration reloaded"
                fi
            done
        ) &
    fi
}

# 检查配置文件
if [[ ! -f "$CONFIG_PATH" ]]; then
    create_default_config
fi

# 更新订阅（如果配置了）
update_subscription

# 验证配置文件
bashio::log.info "Validating Clash configuration..."
if ! clash -t -f "$CONFIG_PATH"; then
    bashio::log.error "Invalid configuration file!"
    bashio::log.info "Falling back to default configuration..."
    create_default_config
fi

# 启动定时更新（如果启用）
schedule_updates

# 显示启动信息
bashio::log.info "Starting Clash..."
bashio::log.info "Configuration file: $CONFIG_PATH"
bashio::log.info "Log level: $LOG_LEVEL"
bashio::log.info "External controller: $EXTERNAL_CONTROLLER"
bashio::log.info "Web dashboard: http://homeassistant-ip:9090/ui"

if [[ -n "$SUBSCRIPTION_URL" ]]; then
    bashio::log.info "Subscription URL: $SUBSCRIPTION_URL"
    bashio::log.info "Auto update: $AUTO_UPDATE"
fi

# 启动Clash
exec clash -f "$CONFIG_PATH" -d /opt/clash