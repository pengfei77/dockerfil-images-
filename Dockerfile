FROM crpi-95ycgp634fv97mlw.cn-hangzhou.personal.cr.aliyuncs.com/pengfei-y/dm:nginx-1.21.6-arm64

# 更新并安装工具（Debian/Ubuntu）
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    vim \
    htop \
    net-tools \      
    zip \
    unzip \
    iputils-ping \   
    netcat-openbsd \  
    && rm -rf /var/lib/apt/lists/*
