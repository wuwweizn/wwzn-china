# syntax=docker/dockerfile:1
ARG BUILD_FROM
FROM ${BUILD_FROM}

SHELL ["/bin/ash", "-o", "pipefail", "-c"]

# 基础工具 & CA 证书
RUN opkg update && \
    opkg install ca-bundle ca-certificates coreutils-nohup bash curl wget && \
    # LuCI 与 Web 服务器
    opkg install uhttpd luci-base luci-mod-admin-full luci-theme-bootstrap luci-i18n-base-zh-cn && \
    # Passwall（含核心依赖，依据可用性适当裁剪/增补）
    opkg install passwall luci-app-passwall iptables-mod-tproxy iptables-mod-extra ip-full dnsmasq-full && \
    # 保障目录
    mkdir -p /data && \
    # 预置 uhttpd 配置（若失败不致命，run.sh 会修正）
    sed -i 's/option listen_http.*/option listen_http "0.0.0.0:8080"/' /etc/config/uhttpd || true

# 复制启动脚本
COPY run.sh /usr/bin/run.sh
RUN chmod +x /usr/bin/run.sh

EXPOSE 8080
CMD ["/usr/bin/run.sh"]