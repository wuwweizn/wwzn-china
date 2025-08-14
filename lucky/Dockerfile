FROM gdy666/lucky:latest

# 设置环境变量
ENV LANG=C.UTF-8 \
    TZ=Asia/Shanghai

# 安装jq用于解析Home Assistant配置
RUN apk add --no-cache jq

# 复制Home Assistant加载项启动脚本
COPY run.sh /run.sh
RUN chmod +x /run.sh

# 创建配置目录
RUN mkdir -p /config

# 暴露端口
EXPOSE 16601

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:16601/ || exit 1

# 启动命令
CMD ["/run.sh"]