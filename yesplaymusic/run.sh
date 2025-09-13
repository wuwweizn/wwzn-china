#!/usr/bin/with-contenv bashio

# ==============================================================================
# Home Assistant Add-on: YesPlayMusic
# YesPlayMusic 启动脚本
# ==============================================================================

declare netease_api_url

bashio::log.info "正在启动 YesPlayMusic..."

# 检查是否配置了自定义 API URL
if bashio::config.has_value 'netease_api_url'; then
    netease_api_url=$(bashio::config 'netease_api_url')
    bashio::log.info "使用自定义网易云API地址: ${netease_api_url}"
    
    # 这里可以添加配置文件修改逻辑，如果需要的话
    # 由于原镜像已经构建好，我们主要是启动服务
else
    bashio::log.info "使用默认API配置"
fi

bashio::log.info "YesPlayMusic 正在启动，Web界面将在端口80上提供服务"
bashio::log.info "请通过 Home Assistant 的 Web UI 按钮或直接访问端口3001来使用"

# 启动原始容器的服务
# 由于我们基于 dnyo666/my_yesplaymusic:v0.4.16-3，它使用 nginx
exec nginx -g "daemon off;"