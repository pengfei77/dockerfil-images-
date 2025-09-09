FROM node:20-alpine

WORKDIR /app

# 方法 2：先卸载默认 Yarn，再安装 1.22.22
RUN npm uninstall -g yarn && \
    npm install -g yarn@1.22.22 && \
    yarn --version
