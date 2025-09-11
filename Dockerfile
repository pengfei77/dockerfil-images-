FROM node:20-alpine

# 设置 Yarn 版本
ENV YARN_VERSION=1.22.22

# 1. 删除预装的 Yarn（如果存在）
RUN rm -f /usr/local/bin/yarn /usr/local/bin/yarnpkg

# 2. 安装依赖工具

RUN apk add --no-cache \
    curl \
    git \
    wget \
    vim \
    net-tools \
    zip \
    unzip \
    iputils \
    netcat-openbsd \
    docker-cli
# 3. 下载并安装指定版本的 Yarn
RUN curl -fsSL https://github.com/yarnpkg/yarn/releases/download/v${YARN_VERSION}/yarn-v${YARN_VERSION}.tar.gz -o yarn.tar.gz && \
    tar -xzf yarn.tar.gz && \
    mv yarn-v${YARN_VERSION} /opt/yarn && \
    ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn && \
    ln -s /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg && \
    rm yarn.tar.gz && \
ARG HELM_VERSION=2.17.0
RUN curl -fsSL -o /tmp/helm.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
    && tar -xzf /tmp/helm.tar.gz -C /tmp \
    && mv /tmp/linux-amd64/helm /usr/local/bin/helm \
    && mv /tmp/linux-amd64/tiller /usr/local/bin/tiller \
    && rm -rf /tmp/helm.tar.gz /tmp/linux-amd64

# 初始化 Helm（仅客户端，Tiller 需要额外部署）
RUN helm init --client-only
    

# 4. 验证安装
RUN node --version && /opt/yarn/bin/yarn --version \
    && docker --version \
    && helm version --client \
    && curl --version \
