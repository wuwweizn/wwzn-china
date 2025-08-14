FROM golang:alpine AS builder
WORKDIR /build
COPY . .
RUN go build -o alist main.go

FROM alpine:3.21.3
WORKDIR /app
COPY --from=builder /build/alist .
COPY config/ ./config/
EXPOSE 5244
CMD ["./alist"]