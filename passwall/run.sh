#!/bin/ash
set -e

# 调整 uhttpd 监听配置
uci set uhttpd.main.listen_http='0.0.0.0:8080' 2>/dev/null || true
uci commit uhttpd 2>/dev/null || true

# 启动基础服务
[ -x /etc/init.d/dnsmasq ] && /etc/init.d/dnsmasq start || true
[ -x /etc/init.d/firewall ] && /etc/init.d/firewall start || true

# 启动 Passwall（若尚未启用/配置，不致命）
if [ -x /etc/init.d/passwall ]; then
  /etc/init.d/passwall enable || true
  /etc/init.d/passwall start || true
fi

# 若将来需要从 HA 配置项写入 UCI，可在此解析 /data/options.json
# 例如：
# if [ -f /data/options.json ]; then
#   SERVER=$(grep -o '"server"\s*:\s*"[^"]*"' /data/options.json | cut -d '"' -f4)
#   [ -n "$SERVER" ] && {
#     uci set passwall.global.enabled='1'
#     # 这里写入具体 UCI 键值
#     uci commit passwall
#   }
# fi

# 以前台模式运行 LuCI Web（保持容器不退出）
exec /usr/sbin/uhttpd -f -h /www -p 0.0.0.0:8080