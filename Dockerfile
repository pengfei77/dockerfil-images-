# 使用官方 Ubuntu 22.04 镜像
FROM ubuntu:22.04

# 设置非交互式安装（避免提示）
ENV DEBIAN_FRONTEND=noninteractive

# 1. 安装基础依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        pnpm \
        ca-certificates \
        gnupg \
        software-properties-common && \
    rm -rf /var/lib/apt/lists/*

# 2. 安装 Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# 3. 安装 Yarn 1.22.22
RUN curl -fsSL https://github.com/yarnpkg/yarn/releases/download/v1.22.22/yarn-v1.22.22.tar.gz -o yarn.tar.gz && \
    tar -xzf yarn.tar.gz && \
    mv yarn-v1.22.22 /opt/yarn && \
    ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn && \
    ln -s /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg && \
    rm yarn.tar.gz

# 4. 安装 pnpm
RUN 

# 5. 验证安装
RUN node --version && \
    yarn --version && \
    pnpm --version

