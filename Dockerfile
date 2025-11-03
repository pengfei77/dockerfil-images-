FROM crpi-95ycgp634fv97mlw.cn-hangzhou.personal.cr.aliyuncs.com/pengfei-y/dm:hr_3
ENV LANG C.UTF-8
ENV TZ Asia/Shanghai
# 配置阿里云镜像源（加速apk包下载）
RUN echo "https://mirrors.aliyun.com/alpine/v3.11/main" > /etc/apk/repositories && \
    echo "https://mirrors.aliyun.com/alpine/v3.11/community" >> /etc/apk/repositories \
# 更新apk索引并安装LibreOffice
RUN apk update && \
    apk add --no-cache libreoffice && \
    # 清理apk缓存（减小镜像体积）
    rm -rf /var/cache/apk/*
