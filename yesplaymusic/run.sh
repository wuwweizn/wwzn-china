#!/usr/bin/env bash

API_URL="${API_URL:-http://47.121.211.116:3001/}"

echo "Starting YesPlayMusic with API: $API_URL"

# 启动生产构建后的服务
npm run serve -- --port 3000 --api "$API_URL"
