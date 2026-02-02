FROM openjdk:8-jdk

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
    # 其他实用工具
    software-properties-common \
    ca-certificates \
    locales \
    sudo \
    && rm -rf /var/lib/apt/lists/*

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
    echo "curl version:" && curl --version 2>&1 | head -1


CMD ["bash"]
