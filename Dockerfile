FROM node:20-alpine

# 安装 PNPM 10.15.0（全局安装）
RUN npm install -g pnpm@10.15.0
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    wget \
    vim \
    net-tools \
    zip \
    unzip \

# 验证 PNPM 版本
RUN pnpm --version
