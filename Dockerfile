FROM crpi-95ycgp634fv97mlw.cn-hangzhou.personal.cr.aliyuncs.com/pengfei-y/dm:hr_3
ENV LANG C.UTF-8
ENV TZ Asia/Shanghai

# 使用 Alpine 官方镜像源
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.11/main/" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.11/community/" >> /etc/apk/repositories

# 更新并安装
RUN apk update && \
    apk add --no-cache libreoffice && \
    rm -rf /var/cache/apk/*
