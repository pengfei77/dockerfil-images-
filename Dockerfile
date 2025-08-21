FROM python:3.12

# 安装系统依赖和 PNPM 10.15.0
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    wget \
    vim \
    net-tools \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*
