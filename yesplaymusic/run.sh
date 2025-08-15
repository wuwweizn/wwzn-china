#!/usr/bin/env bash
API_URL="${API_URL:-http://47.121.211.116:3001/}"
echo "Starting YesPlayMusic with API: $API_URL"

# 启动编译好的版本
npm install -g serve
serve -s dist -l 3000
