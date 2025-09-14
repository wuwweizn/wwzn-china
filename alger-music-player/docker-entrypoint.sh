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
    
    # 等待配置文件生成
    sleep 2
    
    # 修改配置以支持 Home Assistant Ingress
    if [ -f "${DATA_DIR}/config.json" ]; then
        echo "配置 AList 以支持 Home Assistant Ingress..."
        # 使用 sed 修改配置文件，允许所有来源的请求
        sed -i 's/"site_url": ""/"site_url": ""/g' "${DATA_DIR}/config.json"
        sed -i 's/"allow_indexed": false/"allow_indexed": true/g' "${DATA_DIR}/config.json"
    fi
fi

# 启动 AList 服务器
echo "正在启动 AList 服务器..."
exec /opt/alist/alist server --data "${DATA_DIR}" --no-prefix