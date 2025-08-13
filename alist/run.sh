#!/usr/bin/env bash
set -e

# 创建 data 目录
mkdir -p "${HASSIO_DATA:-/data}"

# 进入 data 目录
cd "${HASSIO_DATA:-/data}"

# 启动 Alist
alist server --port ${port:-5244} ${additional_args}
