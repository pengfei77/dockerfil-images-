FROM node:12-stretch
WORKDIR /app

# 安装常用系统工具（curl, wget, vim等）
RUN apt-get update && \
    apt-get install -y \
    curl \
    wget \
    vim \
    git \
    procps \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# 安装 pnpm
RUN npm install -g pnpm@6

# 设置 pnpm 优化配置
RUN pnpm config set store-dir /pnpm/store && \
    pnpm config set concurrent 10

# 验证安装
RUN node --version && npm --version && pnpm --version && curl --version && wget --version
