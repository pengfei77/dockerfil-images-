FROM nginx:latest  # 或 ubuntu:22.04

# 更新源并安装（确保包名正确）
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libnginx-mod-http-brotli && \
    rm -rf /var/lib/apt/lists/*
