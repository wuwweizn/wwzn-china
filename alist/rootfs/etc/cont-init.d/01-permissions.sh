#!/usr/bin/with-contenv bash

# 设置正确的文件权限
chown -R alist:alist /opt/alist
chown -R alist:alist /config
chmod +x /opt/alist/alist