FROM node:20-alpine

# 设置 Yarn 和 pnpm 版本
ENV YARN_VERSION=1.22.22
ENV PNPM_VERSION=8.15.0

# 安装 curl 用于下载
RUN apk add --no-cache curl

# 安装 Yarn
RUN curl -fsSL https://github.com/yarnpkg/yarn/releases/download/v${YARN_VERSION}/yarn-v${YARN_VERSION}.tar.gz -o yarn.tar.gz && \
    tar -xzf yarn.tar.gz && \
    mv yarn-v${YARN_VERSION}/bin/yarn /usr/local/bin/ && \
    mv yarn-v${YARN_VERSION}/bin/yarnpkg /usr/local/bin/ && \
    rm -rf yarn-v${YARN_VERSION} yarn.tar.gz

# 安装 pnpm
RUN curl -fsSL https://get.pnpm.io/install.sh | env PNPM_VERSION=${PNPM_VERSION} sh - && \
    mv /root/.local/share/pnpm/pnpm /usr/local/bin/pnpm && \
    rm -rf /root/.local/share/pnpm

# 验证安装
RUN node --version && yarn --version && pnpm --version
