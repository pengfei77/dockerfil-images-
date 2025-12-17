FROM node:18.20.4-alpine3.19

# 安装 npm 7
RUN npm install -g npm@7.24.2

# 清理缓存
RUN npm cache clean --force && \
    rm -rf /tmp/* /var/tmp/*

RUN apk add --no-cache --update \
    curl \
    wget \
    busybox-extras \  # 提供 telnet
    bind-tools \
    unzip

EXPOSE 3000
CMD ["node"]
