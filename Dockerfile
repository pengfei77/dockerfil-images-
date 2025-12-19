# 使用Node.js 22官方镜像作为基础镜像
FROM node:22-alpine

# 安装时区数据
RUN apk add --no-cache tzdata

# 启用corepack并激活指定版本的pnpm
RUN corepack enable && corepack prepare pnpm@10.22.0 --activate

# 设置pnpm全局目录环境变量
ENV PNPM_HOME="/usr/local/share/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

# 安装pm2（使用pnpm安装）
RUN pnpm add -g pm2

# 创建.pm2目录并设置权限
RUN mkdir /.pm2 \
    && chown -R 1001:0 /.pm2 \
    && chmod -R g=u /.pm2

# 验证安装
RUN node --version && pnpm --version

# 设置工作目录
WORKDIR /app

# 设置默认命令
CMD ["node"]
