#!/bin/bash
set -e

# ─── HA Add-on 通过环境变量注入 options 配置（变量名大写）──────────────────────
PUBLIC_PORT="${PUBLIC_PORT:-58090}"

# ─── 官方镜像固定使用 /app/music 和 /app/conf ─────────────────────────────────
# HA 的 map: share:rw 会将宿主 /share 挂载到容器 /share
# 用软链接把官方路径指向 HA 的共享存储，避免修改官方启动逻辑
mkdir -p /share/xiaomusic/music /share/xiaomusic/conf

# 如果 /app/music 还不是软链接，就替换掉
if [ ! -L /app/music ]; then
    rm -rf /app/music
    ln -s /share/xiaomusic/music /app/music
fi

# /app/conf 软链接
if [ ! -L /app/conf ]; then
    rm -rf /app/conf
    ln -s /share/xiaomusic/conf /app/conf
fi

echo "===================================="
echo "  XiaoMusic Add-on 正在启动..."
echo "  Web 管理界面端口: ${PUBLIC_PORT}"
echo "  音乐目录 -> /share/xiaomusic/music"
echo "  配置目录 -> /share/xiaomusic/conf"
echo "===================================="
echo "  访问地址: http://homeassistant.local:${PUBLIC_PORT}"
echo "  初次使用需在 Web 页面填写小米账号密码。"
echo "===================================="

# ─── 用官方镜像原生的 supervisord 启动（保持和官方完全一致的启动方式）──────────
export XIAOMUSIC_PUBLIC_PORT="${PUBLIC_PORT}"

exec /usr/bin/supervisord -c /app/supervisord.conf
