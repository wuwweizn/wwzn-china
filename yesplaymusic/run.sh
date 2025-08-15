#!/usr/bin/env bash
echo "Starting YesPlayMusic with API: $API_URL"
# 如果镜像支持 API_URL 环境变量，可以直接运行
docker-entrypoint.sh
