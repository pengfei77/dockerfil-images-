FROM --platform=linux/arm64 bitnami/redis-sentinel:6.2.14-debian-12-r25

# 切换到 root 用户编译 jemalloc
USER root

# 安装依赖并编译 jemalloc（适配 64KB 页）
RUN apt-get update && \
    apt-get install -y build-essential wget && \
    wget https://github.com/jemalloc/jemalloc/releases/download/5.3.0/jemalloc-5.3.0.tar.bz2 && \
    tar -xjf jemalloc-5.3.0.tar.bz2 && \
    cd jemalloc-5.3.0 && \
    ./configure --with-lg-page=16 && \
    make && \
    make install && \
    echo "/usr/local/lib" > /etc/ld.so.conf.d/jemalloc.conf && \
    ldconfig && \
    apt-get remove -y build-essential wget && \
    rm -rf /var/lib/apt/lists/* /jemalloc-5.3.0*

# 启用新编译的 jemalloc
ENV LD_PRELOAD=/usr/local/lib/libjemalloc.so.2

# 切换回非 root 用户
USER 1001
