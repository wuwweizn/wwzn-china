# 使用 GHCR 官方 amd64 镜像作为基础镜像
FROM ghcr.io/desmond-dong/webtunnel-aarch64:25.06.12

# 设置挂载目录（保存配置）
VOLUME ["/data/.webtunnel"]

# 设置入口点（已经在基础镜像里通常有 ENTRYPOINT，可以覆盖）
ENTRYPOINT ["/WebTunnelCore", "--config=/data/.webtunnel"]
