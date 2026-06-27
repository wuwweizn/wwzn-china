#!/bin/bash
set -e

echo "[Token Hub] 正在启动 HACS Token Hub v1.0.0..."
echo "[Token Hub] 数据目录: /data"
echo "[Token Hub] Web UI: http://localhost:8765"

cd /app
exec uvicorn main:app --host 0.0.0.0 --port 8765 --log-level info
