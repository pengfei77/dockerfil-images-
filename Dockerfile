# 使用Node.js 22官方镜像作为基础镜像
FROM node:22-alpine

# 安装指定版本的pnpm
RUN npm install -g pnpm@10.22.0

# 验证安装
RUN node --version && pnpm --version

# 设置默认命令
CMD ["node"]
