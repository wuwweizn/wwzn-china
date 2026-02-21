ARG BUILD_FROM=hanxi/xiaomusic:latest
FROM ${BUILD_FROM}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# 安装 bashio
RUN apt-get update && apt-get install -y curl && \
    curl -J -L -o /tmp/bashio.tar.gz \
    "https://github.com/hassio-addons/bashio/archive/refs/tags/v0.16.2.tar.gz" && \
    mkdir /tmp/bashio && \
    tar zxvf /tmp/bashio.tar.gz --strip 1 -C /tmp/bashio && \
    mv /tmp/bashio/lib /usr/lib/bashio && \
    ln -s /usr/lib/bashio/bashio.sh /usr/bin/bashio && \
    rm -rf /tmp/bashio /tmp/bashio.tar.gz && \
    apt-get clean

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD ["/bin/bash", "/run.sh"]
