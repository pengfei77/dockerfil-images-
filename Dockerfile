FROM python:3.12-alpine

# 安装系统工具（使用 apk）
RUN apk add --no-cache \
    curl \
    git \
    wget \
    vim

# 验证安装（可选）
RUN curl --version && git --version && wget --version && vim --version
