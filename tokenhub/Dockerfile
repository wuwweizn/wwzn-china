ARG BUILD_FROM=python:3.11-slim
FROM $BUILD_FROM

# 安装依赖（slim 有预编译 wheel，无需编译工具）
RUN pip3 install --no-cache-dir fastapi uvicorn aiohttp pydantic

# 复制应用代码
COPY app/ /app/

# 复制启动脚本
COPY run.sh /usr/bin/run.sh
RUN chmod +x /usr/bin/run.sh

EXPOSE 8765

CMD ["/usr/bin/run.sh"]
