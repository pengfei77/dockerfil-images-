# 应用基础镜像
FROM  nginx:1.27
RUN apt-get update && \
    apt-get install -y --no-install-recommends libnginx-mod-http-brotli && \
    rm -rf /var/lib/apt/lists/*


