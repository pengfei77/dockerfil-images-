

FROM --platform=linux/arm64 bitnami/redis-sentinel:6.2.14-debian-12-r25


# 切换到 root 用户
USER root

# 创建空库替换 jemalloc
RUN touch /tmp/empty.c && \
    gcc -shared -o /usr/lib/fake_jemalloc.so /tmp/empty.c && \
    ln -sf /usr/lib/fake_jemalloc.so /usr/lib/libjemalloc.so.2 && \
    rm /tmp/empty.c

# 验证降级是否成功
RUN bash -c '\
    if ldd $(which redis-server) | grep -q "libjemalloc"; then \
        echo "降级失败：jemalloc 仍在加载"; \
        exit 1; \
    else \
        echo "降级成功：使用 libc"; \
    fi'

# 可选：显式禁用 jemalloc（双重保障）
ENV LD_PRELOAD=""


# 切换回非 root 用户
USER 1001

