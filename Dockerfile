FROM node:20-alpine

# 设置 Yarn 版本
ENV YARN_VERSION=1.22.22

# 1. 安装依赖工具
RUN apk add --no-cache curl

# 2. 下载并安装 Yarn
RUN curl -fsSL https://github.com/yarnpkg/yarn/releases/download/v${YARN_VERSION}/yarn-v${YARN_VERSION}.tar.gz -o yarn.tar.gz && \
    tar -xzf yarn.tar.gz && \
    mv yarn-v${YARN_VERSION} /opt/yarn && \
    ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn && \
    ln -s /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg && \
    rm yarn.tar.gz && \
    apk del curl

# 3. 验证安装
RUN node --version && /opt/yarn/bin/yarn --version
