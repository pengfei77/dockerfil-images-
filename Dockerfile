# 构建阶段 - ARM64
FROM --platform=linux/arm64 golang:1.21-alpine AS builder

RUN apk add --no-cache git
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o secrets-controller ./cmd/controller

# 运行阶段 - ARM64
FROM --platform=linux/arm64 alpine:latest

RUN apk --no-cache add ca-certificates tzdata curl
RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup

WORKDIR /root/
COPY --from=builder /app/secrets-controller .
RUN mkdir -p /fixed/path && chown -R appuser:appgroup /fixed/path

USER appuser

CMD ["./secrets-controller"]
