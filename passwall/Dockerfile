ARG BUILD_FROM
FROM $BUILD_FROM

ARG BUILD_ARCH
ARG PASSWALL_VERSION

RUN apk add --no-cache bash curl
# 这里需要你替换成 Passwall 编译/安装步骤
# 比如：下载已经编译好的 passwall 二进制并放到 /usr/bin

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD [ "/run.sh" ]
