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

# 添加音源参数 (UnblockNeteaseMusic/server 使用冒号分隔音源)
if [ -n "${SOURCES}" ]; then
    ARGS="${ARGS} -o ${SOURCES}"
    echo "[INFO] 使用音源: ${SOURCES}"
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