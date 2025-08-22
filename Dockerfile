FROM node:12-stretch
WORKDIR /app

# 安装 pnpm
RUN npm install -g pnpm@6
