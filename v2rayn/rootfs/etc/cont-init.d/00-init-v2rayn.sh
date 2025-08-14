#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: v2rayN
# Configures v2rayN before startup
# ==============================================================================

readonly CONFIG_PATH="/data/v2rayn"
readonly SHARE_PATH="/share/v2rayn"
readonly LOG_PATH="/var/log/v2rayn"

# 创建必要的目录
bashio::log.info "准备 v2rayN 环境..."

mkdir -p \
    "${CONFIG_PATH}" \
    "${SHARE_PATH}" \
    "${LOG_PATH}" \
    "${SHARE_PATH}/backups" \
    "${SHARE_PATH}/logs"

# 设置目录权限
chown -R v2rayn:v2rayn \
    "${CONFIG_PATH}" \
    "${SHARE_PATH}" \
    "${LOG_PATH}"

chmod -R 755 \
    "${CONFIG_PATH}" \
    "${SHARE_PATH}" \
    "${LOG_PATH}"

# 检查配置文件
if bashio::config.has_value 'servers' && bashio::config.equals 'servers' '[]'; then
    bashio::log.warning "未配置代理服务器。v2rayN 将以直连模式运行。"
fi

# 验证端口配置
readonly HTTP_PORT=$(bashio::config 'http_port')
readonly SOCKS_PORT=$(bashio::config 'socks_port')
readonly API_PORT=$(bashio::config 'api_port')

if [[ "${HTTP_PORT}" -eq "${SOCKS_PORT}" ]] || \
   [[ "${HTTP_PORT}" -eq "${API_PORT}" ]] || \
   [[ "${SOCKS_PORT}" -eq "${API_PORT}" ]]; then
    bashio::log.fatal "检测到端口冲突。所有端口必须不同。"
    bashio::log.fatal "HTTP: ${HTTP_PORT}, SOCKS: ${SOCKS_PORT}, API: ${API_PORT}"
    exit 1
fi

# 检查核心文件
if [[ ! -f "/usr/local/bin/v2ray" ]] && [[ ! -f "/usr/local/bin/xray" ]]; then
    bashio::log.fatal "未找到 v2ray 或 xray 核心文件！"
    exit 1
fi

# 检查geo数据文件
if [[ ! -f "/usr/local/bin/geosite.dat" ]] || [[ ! -f "/usr/local/bin/geoip.dat" ]]; then
    bashio::log.warning "缺少 Geo 数据文件。正在下载..."
    
    # 下载geo数据文件
    curl -fsSL https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat \
        -o /usr/local/bin/geosite.dat || bashio::log.warning "下载 geosite.dat 失败"
    
    curl -fsSL https://github.com/v2fly/geoip/releases/latest/download/geoip.dat \
        -o /usr/local/bin/geoip.dat || bashio::log.warning "下载 geoip.dat 失败"
fi

# 显示配置摘要
bashio::log.info "配置摘要:"
bashio::log.info "- HTTP 代理: $(bashio::config 'allow_lan' && echo "0.0.0.0" || echo "127.0.0.1"):${HTTP_PORT}"
bashio::log.info "- SOCKS 代理: $(bashio::config 'allow_lan' && echo "0.0.0.0" || echo "127.0.0.1"):${SOCKS_PORT}"
bashio::log.info "- API 端口: 127.0.0.1:${API_PORT}"
bashio::log.info "- Web 界面: http://[HOST]:[PORT:8080]"
bashio::log.info "- 允许局域网: $(bashio::config 'allow_lan')"
bashio::log.info "- 流量嗅探: $(bashio::config 'enable_sniffing')"
bashio::log.info "- 路由规则: $(bashio::config 'enable_routing')"
bashio::log.info "- DNS 服务: $(bashio::config 'dns.enable')"

bashio::log.info "v2rayN 初始化完成！"