# 使用Node.js 22官方镜像作为基础镜像
FROM node:22-alpine

# 安装时区数据
RUN apk add --no-cache tzdata

# 启用corepack（Node.js 22内置功能）
RUN corepack enable

# 设置pnpm环境变量
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

# 安装指定版本的pnpm
RUN corepack prepare pnpm@10.22.0 --activate

# 安装pm2
RUN pnpm add -g pm2

# 创建必要的目录并设置权限
RUN mkdir /.pm2 /app \
    && chown -R 1001:0 /.pm2 /app /pnpm \
    && chmod -R g=u /.pm2 /app /pnpm

# 验证安装
RUN node --version && pnpm --version

# 设置NEXT_PUBLIC_BASE_PATH环境变量
ENV NEXT_PUBLIC_BASE_PATH=""

# 设置工作目录
WORKDIR /app

# 设置默认命令
CMD ["node"]
