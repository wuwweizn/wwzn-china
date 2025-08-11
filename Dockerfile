FROM alpine:3.18
RUN apk add --no-cache curl
CMD ["echo", "Hello from my GHCR package!"]
