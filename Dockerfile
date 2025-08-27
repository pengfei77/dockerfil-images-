FROM --platform linux/arm64 nginx:1.27.4

# 更新包列表并安装常用工具
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    unzip \
    curl \
    wget \
    vim \
    nano \
    net-tools \
    iputils-ping \
    dnsutils \
    procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
