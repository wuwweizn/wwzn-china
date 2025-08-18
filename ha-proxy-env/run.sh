#!/usr/bin/env bash
set -e

echo "🔌 Setting proxy environment..."
export HTTP_PROXY="${HTTP_PROXY:-}"
export HTTPS_PROXY="${HTTPS_PROXY:-}"

echo "✅ HTTP_PROXY=$HTTP_PROXY"
echo "✅ HTTPS_PROXY=$HTTPS_PROXY"

# 保持容器运行，不让 HA 以为崩溃了
tail -f /dev/null
