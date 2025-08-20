FROM node:20-alpine

# 安装 PNPM 10.15.0（全局安装）
RUN apk add --no-cache \
    ca-certificates \
    curl \
    git \
    wget \
    vim \
    net-tools \
    zip \
    unzip

# 安装指定版本的 PNPM
RUN npm install -g pnpm@10.15.0

# 验证安装
RUN pnpm --version

