# 应用基础镜像
FROM  nginx:1.27
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libnginx-mod-http-brotli && \
    rm -rf /var/lib/apt/lists/*

# 启用模块
RUN echo "load_module modules/ngx_http_brotli_filter_module.so;" > /etc/nginx/modules-enabled/50-brotli.conf && \
    echo "load_module modules/ngx_http_brotli_static_module.so;" >> /etc/nginx/modules-enabled/50-brotli.conf
