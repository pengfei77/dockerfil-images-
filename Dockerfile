FROM --platform=linux/arm64 bitnami/redis-sentinel:6.2.14-debian-12-r25

# 切换到 root 用户编译 jemalloc
USER root



