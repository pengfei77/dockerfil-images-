FROM --platform=linux/arm64 bitnami/redis-sentinel:6.2.14-debian-12-r25
RUN apt-get update && apt-get install -y build-essential \
    && wget https://github.com/jemalloc/jemalloc/releases/download/5.3.0/jemalloc-5.3.0.tar.bz2 \
    && tar -xjf jemalloc-5.3.0.tar.bz2 \
    && cd jemalloc-5.3.0 && ./configure --with-lg-page=16 \  # 64KB=2^16 → lg-page=16
    && make && make install
