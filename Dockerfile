

FROM --platform=linux/arm64 bitnami/redis-sentinel:6.2.14-debian-12-r25


FROM your-redis-image

# 切换到 root 用户
USER root

# 安装 gcc 编译工具（Alpine 或 Debian 系）
RUN if [ -f /etc/alpine-release ]; then \
        apk add --no-cache gcc libc-dev; \
    else \
        apt-get update && apt-get install -y gcc && rm -rf /var/lib/apt/lists/*; \
    fi

# 创建空库替换 jemalloc
RUN touch /tmp/empty.c && \
    gcc -shared -o /usr/lib/fake_jemalloc.so /tmp/empty.c && \
    ln -sf /usr/lib/fake_jemalloc.so /usr/lib/libjemalloc.so.2 && \
    rm /tmp/empty.c

# 验证替换结果
RUN bash -c '\
    if ldd $(which redis-server) | grep -q "libjemalloc"; then \
        echo "Error: jemalloc still loaded"; exit 1; \
    else \
        echo "Success: Using libc now"; \
    fi'




# 切换回非 root 用户
USER 1001

