#!/usr/bin/env bash

set -e

echo "Starting Lucky Upstream Sync Add-on..."

# 获取最新 upstream tag
LATEST_TAG=$(git ls-remote --tags https://github.com/gdy666/lucky.git | \
             awk -F/ '{print $3}' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n1)
VERSION=${LATEST_TAG#v}

echo "Latest upstream tag: $LATEST_TAG (version $VERSION)"

# 生成 pull.txt
echo "docker pull ghcr.io/wuwweizn/lucky:latest" > /data/pull.txt
echo "docker pull ghcr.io/wuwweizn/lucky:${VERSION}" >> /data/pull.txt

echo "pull.txt generated at /data/pull.txt"

# HA 加载项可以一直运行
tail -f /dev/null
