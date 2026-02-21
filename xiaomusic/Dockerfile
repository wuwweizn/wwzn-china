ARG BUILD_FROM=hanxi/xiaomusic:latest
FROM ${BUILD_FROM}

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD ["/bin/bash", "/run.sh"]
