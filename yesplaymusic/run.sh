#!/usr/bin/env bash

# 默认 API 地址，如果 HA 用户在配置里没有改
API_URL="${API_URL:-http://47.121.211.116:3001/}"

echo "Starting YesPlayMusic with API: $API_URL"

# 启动 YesPlayMusic
npm start -- --port 3000 --api "$API_URL"
