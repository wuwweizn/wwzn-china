#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

export HOME=/config

PIDS=

notify() {
    for N in $(ls /etc/logmonitor/targets.d/*/send)
    do
       "$N" "$1" "$2" "$3" &
       PIDS="$PIDS $!"
    done
}

# Verify support for membarrier.
if ! /usr/bin/membarrier_check 2>/dev/null; then
   notify "$APP_NAME requires the membarrier system call." "$APP_NAME is likely to crash because it requires the membarrier system call.  See the documentation of this Docker container to find out how this system call can be allowed." "WARNING"
fi

# Wait for all PIDs to terminate.
set +e
for PID in "$PIDS"; do
   wait $PID
done
set -e

# Symbolic links for persistent storage on HA
if [ ! -d "/data/profile" ]; then
  mv /config/profile /data
else
  rm -rf /config/profile
fi
ln -s /data/profile /config/profile

if [ ! -d "/share/firefox" ]; then
  mkdir -p /share/firefox
fi
rm -rf /config/downloads

ln -s /share/firefox /config/downloads

/usr/bin/firefox --version
exec /usr/bin/firefox "$@" >> /config/log/firefox/output.log 2>> /config/log/firefox/error.log