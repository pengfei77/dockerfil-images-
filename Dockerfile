# 使用Node.js 22官方镜像作为基础镜像
FROM node:22-alpine

# 安装指定版本的pnpm
RUN npm install -g pnpm@10.22.0

# 验证安装
RUN node --version && pnpm --version
RUN apk add --no-cache tzdata
RUN corepack enable \
    && pnpm setup \
    && export PNPM_HOME="/usr/local/bin" \
    && export PATH="$PNPM_HOME:$PATH"
RUN pnpm add -g pm2 \
    && mkdir /.pm2 \
    && chown -R 1001:0 /.pm2 /app/web \
    && chmod -R g=u /.pm2 /app/web



# 设置默认命令
CMD ["node"]
