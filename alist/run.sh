#!/bin/bash
set -e

# 设置数据目录
export DATA_DIR="/data"

# 创建目录（如果不存在）
mkdir -p "${DATA_DIR}"

# 如果配置文件不存在，生成初始管理员密码
if [ ! -f "${DATA_DIR}/config.json" ]; then
    echo "首次运行检测到，正在生成管理员密码..."
    /opt/alist/alist admin random --data "${DATA_DIR}"
    echo "管理员密码已生成，请查看上面的输出。"
fi

# 启动 AList 服务器
echo "正在启动 AList 服务器..."
exec /opt/alist/alist server --data "${DATA_DIR}" --no-prefix