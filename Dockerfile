FROM node:22-alpine

# 设置工作目录
WORKDIR /app

# 安装 pnpm（全局）
RUN npm install -g pnpm
