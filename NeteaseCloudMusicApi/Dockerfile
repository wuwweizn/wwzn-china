ARG BUILD_FROM
FROM $BUILD_FROM

RUN apk add --no-cache openssl git && \
    rm -rf /var/cache/apk/*

RUN git clone git@github.com:Binaryify/NeteaseCloudMusicApi.git && \
    cd NeteaseCloudMusicApi && \
    npm install

ENV LANG C.UTF-8
ENV TZ=Asia/Shanghai
EXPOSE map[3000/tcp:{}]
CMD [ "node app.js" ]
