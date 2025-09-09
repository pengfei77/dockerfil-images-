FROM node:20-alpine

# 设置工作目录
WORKDIR /app

# 安装 Yarn 1.22.22 并验证版本
RUN npm install -g yarn@1.22.22 && \
    yarn --version
