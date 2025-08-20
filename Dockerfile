FROM node:20-alpine

# 安装 PNPM 10.15.0（全局安装）
RUN npm install -g pnpm@10.15.0

# 验证 PNPM 版本
RUN pnpm --version
