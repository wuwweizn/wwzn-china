FROM alpine:3.18
RUN apk add --no-cache curl
COPY . /app
WORKDIR /app
CMD ["./run.sh"]
