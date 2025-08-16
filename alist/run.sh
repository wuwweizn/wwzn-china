#!/bin/bash
set -e

# Set data directory
export DATA_DIR="/data"

# Create directories if they don't exist
mkdir -p "${DATA_DIR}"

# Change to working directory
cd /opt/alist

# Check if config exists, if not, create initial admin password
if [ ! -f "${DATA_DIR}/config.json" ]; then
    echo "First run detected, generating admin password..."
    ./alist admin random --data "${DATA_DIR}"
fi

# Start AList server
echo "Starting AList server..."
exec ./alist server --data "${DATA_DIR}" --no-prefix