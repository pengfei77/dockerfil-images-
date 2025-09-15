FROM node:20-alpine


ENV HELM_VERSION=2.17.0

# 1. 删除预装的 Yarn
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

RUN curl -fsSL -o /tmp/helm.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
    && tar -xzf /tmp/helm.tar.gz -C /tmp \
    && mv /tmp/linux-amd64/helm /usr/local/bin/helm \
    && mv /tmp/linux-amd64/tiller /usr/local/bin/tiller \
    && rm -rf /tmp/helm.tar.gz /tmp/linux-amd64

# 初始化 Helm（仅客户端，Tiller 需要额外部署）
RUN helm init --client-only
    

# 4. 验证安装
RUN docker --version \
    && helm version --client \
    && curl --version \
