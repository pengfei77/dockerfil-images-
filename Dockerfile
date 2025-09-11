FROM --platform=linux/arm64 bitnami/redis-sentinel:6.2.14-debian-12-r25
USER root
RUN mkdir -p /var/lib/apt/lists/partial && \
    apt-get update && \
    apt-get install -y libjemalloc-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 启用 jemalloc
ENV LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libjemalloc.so.2

   
