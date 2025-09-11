

FROM --platform=linux/arm64 bitnami/redis-sentinel:6.2.14-debian-12-r25

# 切换到 root 用户
USER root
ENV LD_PRELOAD=""

# 安装编译工具和依赖
RUN apt-get update && \
    apt-get install -y build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 创建空库替换 jemalloc
RUN touch /tmp/empty.c && \
    gcc -shared -o /usr/lib/fake_jemalloc.so /tmp/empty.c && \
    ln -sf /usr/lib/fake_jemalloc.so /usr/lib/aarch64-linux-gnu/libjemalloc.so.2 && \
    rm /tmp/empty.c

# 验证替换结果
RUN bash -c '\
    if ldd $(which redis-sentinel) | grep -q "libjemalloc"; then \
        echo "Error: jemalloc still loaded"; exit 1; \
    else \
        echo "Success: Using libc now"; \
    fi'


# 切换回非 root 用户
USER 1001

