FROM node:12-alpine
WORKDIR /app

# Alpine 使用 apk 包管理器
RUN apk update && \
    apk add --no-cache \
    curl \
    wget \
    vim \
    git

# 安装 pnpm
RUN npm install -g pnpm@6
