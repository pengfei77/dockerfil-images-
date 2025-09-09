# 使用官方 Node.js 20 Alpine 镜像
FROM node:20-alpine

# 设置 Yarn 和 pnpm 版本
ENV YARN_VERSION=1.22.22

# 1. 安装 Yarn（完整目录结构）
RUN apk add --no-cache curl && \
    curl -fsSL https://github.com/yarnpkg/yarn/releases/download/v${YARN_VERSION}/yarn-v${YARN_VERSION}.tar.gz -o yarn.tar.gz && \
    tar -xzf yarn.tar.gz && \
    mv yarn-v${YARN_VERSION} /opt/yarn && \
    ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn && \
    ln -s /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg && \
    rm yarn.tar.gz && \
    apk del curl

# 2. 安装 pnpm（通过 Alpine 官方源）
RUN apk add --no-cache pnpm

# 验证安装
RUN node --version && \
    /opt/yarn/bin/yarn --version && \
    pnpm --version

