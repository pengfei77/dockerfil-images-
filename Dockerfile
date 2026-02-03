# 基于原镜像
FROM crpi-95ycgp634fv97mlw.cn-hangzhou.personal.cr.aliyuncs.com/pengfei-y/openjdk:8-jdk-v2

# 安装依赖（Debian/Ubuntu 系）
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libcups2 \
        libxrender1 \
        libfontconfig1 \
        libxext6 \
        libfreetype6 \
        libpng16-16 \
        libjpeg62-turbo \
        libxinerama1 \
        libxcursor1 \
        libxrandr2 \
        libxft2 \
        libgl1-mesa-glx \
        libgl1-mesa-dri && \
    rm -rf /var/lib/apt/lists/*
