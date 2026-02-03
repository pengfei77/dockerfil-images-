# 使用华为云镜像源的基础镜像
FROM swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/openjdk:8-jdk

# 切换为 root 用户安装软件#
USER root

# 更新并安装常用工具
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # 网络工具
    net-tools \
    iproute2 \
    iputils-ping \
    curl \
    wget \
    telnet \
    dnsutils \
    netcat-openbsd \
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
    # 包管理工具
    alien \
    dpkg-dev \
    debhelper \
    build-essential \
    # 字体和显示相关
    fonts-dejavu \
    fonts-liberation \
    fonts-wqy-zenhei \
    # 系统工具
    ca-certificates \
    locales \
    # X11 相关
    xvfb \
    xfonts-base \
    xfonts-75dpi \
    fontconfig \
    libxrender1 \
    libxext6 \
    libx11-6 \
    libjpeg62-turbo \
    libssl1.1 \
    # LibreOffice 依赖
    libcairo2 \
    libgl1-mesa-glx \
    libsm6 \
    libxinerama1 \
    libxcb-shm0 \
    libxcb-render0 \
    libxrender1 \
    libxslt1.1 \
    libxcb-shape0 \
    libxcb-randr0 \
    libxcb-xfixes0 \
    libxcb-sync1 \
    libxcb-xinerama0 \
    libxcb-xkb1 \
    libxcb-keysyms1 \
    libxcb-image0 \
    libxcb-icccm4 \
    libxcb-shape0 \
    libharfbuzz0b \
    # wkhtmltopdf 依赖
    libssl-dev \
    libxrender-dev \
    libfontconfig1 \
    libfreetype6 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*





# 设置时区
RUN ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone






# 默认启动命令
CMD ["bash"]
