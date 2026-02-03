FROM swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/openjdk:8-jdk

# 切换为 root 用户安装软件
USER root

# 更新并安装常用工具
RUN apt-get update && \
    apt-get install -y \
    # 网络工具
    net-tools \
    iproute2 \
    iputils-ping \
    curl \
    wget \
    telnet \
    dnsutils \
    netcat \
    nmap \
    # 系统监控
    lsof \
    procps \
    htop \
    iotop \
    iftop \
    sysstat \
    # 文本处理
    vim \
    nano \
    less \
    tree \
    jq \
    # 压缩工具
    zip \
    unzip \
    bzip2 \
    xz-utils \
    # 版本控制
    git \
    # 调试工具
    strace \
    ltrace \
    tcpdump \
    # 包管理工具（包括 alien 用于 rpm 转 deb）
    alien \
    dpkg-dev \
    debhelper \
    build-essential \
    # 图形和字体相关库
    libxrender1 \
    libfontconfig1 \
    libxext6 \
    libfreetype6 \
    libpng16-16 \
    libjpeg62-turbo \
    libjpeg-turbo8 \
    libxinerama1 \
    libxcursor1 \
    libxrandr2 \
    libxft2 \
    libcups2 \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    libglu1-mesa \
    # 虚拟显示服务器（xvfb）
    xvfb \
    # 其他实用工具
    software-properties-common \
    ca-certificates \
    locales \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# 注意：rpm 包本身是 Red Hat 系统的，在 Debian/Ubuntu 上通常不建议直接安装
# 如果需要处理 rpm 文件，可以使用 alien 工具转换
# 如果确实需要 rpm 命令，可以安装 rpm-common（但功能有限）
# RUN apt-get install -y rpm-common

# 设置时区
RUN ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# 设置语言环境
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# 验证安装
RUN java -version && \
    echo "lsof version:" && lsof --version 2>&1 | head -1 && \
    echo "curl version:" && curl --version 2>&1 | head -1 && \
    echo "xvfb version:" && Xvfb -help 2>&1 | head -1 && \
    echo "alien version:" && alien --version

CMD ["bash"]
