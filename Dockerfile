FROM nginx:latest

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libnginx-mod-http-brotli && \
    rm -rf /var/lib/apt/lists/*
