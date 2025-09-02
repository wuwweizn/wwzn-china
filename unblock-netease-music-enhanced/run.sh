#!/usr/bin/with-contenv bashio

# 从Home Assistant配置读取选项
PORT=$(bashio::config 'port')
SOURCES=$(bashio::config 'sources')
STRICT=$(bashio::config 'strict')
LOG_LEVEL=$(bashio::config 'log_level')

# 设置默认值
PORT=${PORT:-8080}
SOURCES=${SOURCES:-"kuwo:kugou:migu"}
STRICT=${STRICT:-false}
LOG_LEVEL=${LOG_LEVEL:-"info"}

echo "[INFO] 启动 UnblockNeteaseMusic Server (增强版)..."
echo "[INFO] 端口: ${PORT}"
echo "[INFO] 音源: ${SOURCES}"
echo "[INFO] 严格模式: ${STRICT}"
echo "[INFO] 日志级别: ${LOG_LEVEL}"

# 构建启动参数
ARGS=""

# 添加端口参数
ARGS="${ARGS} -p ${PORT}"

# 添加音源参数 (每个音源单独使用 -o 参数)
if [ -n "${SOURCES}" ]; then
    # 将冒号分隔的音源转换为单独的参数
    SOURCE_LIST=$(echo "${SOURCES}" | tr ':' ' ')
    for source in ${SOURCE_LIST}; do
        ARGS="${ARGS} -o ${source}"
        echo "[INFO] 添加音源: ${source}"
    done
else
    # 默认音源，每个单独添加
    ARGS="${ARGS} -o kuwo -o kugou -o migu"
    echo "[INFO] 使用默认音源: kuwo, kugou, migu"
fi

# 添加严格模式
if [ "${STRICT}" = "true" ]; then
    ARGS="${ARGS} -s"
    echo "[INFO] 启用严格模式"
fi

# 设置日志级别环境变量
case "${LOG_LEVEL}" in
    "debug")
        export LOG_LEVEL="debug"
        ;;
    "info")
        export LOG_LEVEL="info"
        ;;
    "warn")
        export LOG_LEVEL="warn"
        ;;
    "error")
        export LOG_LEVEL="error"
        ;;
esac

echo "[INFO] 启动参数: unblockneteasemusic ${ARGS}"
echo "[INFO] 🚀 启动服务..."

# 启动服务 (使用全局安装的命令)
exec unblockneteasemusic ${ARGS}