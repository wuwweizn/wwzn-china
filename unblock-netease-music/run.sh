#!/usr/bin/with-contenv bashio

# 从Home Assistant配置读取选项
PORT=$(bashio::config 'port')
SOURCES=$(bashio::config 'sources')

# 设置默认值
PORT=${PORT:-8080}
SOURCES=${SOURCES:-"kuwo,kugou,migu"}

echo "[INFO] 启动 UnblockNeteaseMusic..."
echo "[INFO] 端口: ${PORT}"
echo "[INFO] 音源: ${SOURCES}"

# 检查应用文件
if [ ! -f "/app/app.js" ]; then
    echo "[ERROR] /app/app.js 不存在!"
    exit 1
fi

# 切换到应用目录
cd /app

# 转换音源格式 (逗号分隔转为空格分隔)
SOURCE_LIST=$(echo "${SOURCES}" | tr ',' ' ')

# 构建参数
ARGS="-p ${PORT} -a 0.0.0.0"

# 添加音源参数
for source in ${SOURCE_LIST}; do
    ARGS="${ARGS} -o ${source}"
    echo "[INFO] 添加音源: ${source}"
done

echo "[INFO] 启动参数: node app.js ${ARGS}"
echo "[INFO] 🚀 启动服务..."

# 启动服务
exec node app.js ${ARGS}