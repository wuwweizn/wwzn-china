FROM node:18-alpine

WORKDIR /app

RUN apk add --no-cache bash curl

# 下载官方最新构建好的 Release
RUN curl -L https://github.com/qier222/YesPlayMusic/releases/latest/download/YesPlayMusic.tar.gz \
    -o ypm.tar.gz && \
    mkdir -p /app && \
    tar -xzf ypm.tar.gz -C /app && \
    rm ypm.tar.gz

COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 3000

CMD ["/run.sh"]
