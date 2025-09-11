FROM --platform=linux/arm64 bitnami/redis-sentinel:6.2.14-debian-12-r25

RUN apt-get update && \
    apt-get install -y libjemalloc-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 启用 jemalloc（通过环境变量）
ENV LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libjemalloc.so.2

   
