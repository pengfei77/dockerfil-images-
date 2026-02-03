# 使用华为云镜像源的基础镜像
FROM swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/openjdk:8-jdk

# 切换为 root 用户安装软件
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

# 安装 LibreOffice 6.3 到 /opt/libreoffice6.3
RUN mkdir -p /opt/libreoffice6.3 && cd /opt/libreoffice6.3 && \
    # 下载 LibreOffice 6.3.7.2
    wget https://downloadarchive.documentfoundation.org/libreoffice/old/6.3.7.2/deb/x86_64/LibreOffice_6.3.7.2_Linux_x86-64_deb.tar.gz && \
    wget https://downloadarchive.documentfoundation.org/libreoffice/old/6.3.7.2/deb/x86_64/LibreOffice_6.3.7.2_Linux_x86-64_deb_langpack_zh-CN.tar.gz && \
    # 解压
    tar -xzf LibreOffice_6.3.7.2_Linux_x86-64_deb.tar.gz && \
    tar -xzf LibreOffice_6.3.7.2_Linux_x86-64_deb_langpack_zh-CN.tar.gz && \
    # 安装主程序
    cd LibreOffice_6.3.7.2_Linux_x86-64_deb/DEBS/ && \
    dpkg -i *.deb && \
    # 安装中文语言包
    cd ../../LibreOffice_6.3.7.2_Linux_x86-64_deb_langpack_zh-CN/DEBS/ && \
    dpkg -i *.deb && \
    # 清理临时文件
    cd /opt/libreoffice6.3 && \
    rm -rf LibreOffice_6.3.7.2_Linux_x86-64_deb.tar.gz \
           LibreOffice_6.3.7.2_Linux_x86-64_deb_langpack_zh-CN.tar.gz \
           LibreOffice_6.3.7.2_Linux_x86-64_deb \
           LibreOffice_6.3.7.2_Linux_x86-64_deb_langpack_zh-CN && \
    # 创建软链接到 /usr/local/bin
    ln -sf /opt/libreoffice6.3/program/* /usr/local/bin/

# 修复可能的依赖问题
RUN apt-get update && \
    apt-get install -f -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 安装 wkhtmltopdf 到 /opt/wkhhtml/bin
RUN mkdir -p /opt/wkhhtml/bin /tmp/wkhtml && cd /tmp/wkhtml && \
    # 下载 wkhtmltopdf
    wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.buster_amd64.deb && \
    # 提取 deb 包中的文件
    dpkg -x wkhtmltox_0.12.6-1.buster_amd64.deb . && \
    # 复制可执行文件到 /opt/wkhhtml/bin
    cp -r usr/local/bin/* /opt/wkhhtml/bin/ && \
    # 复制库文件到 /opt/wkhhtml/lib
    cp -r usr/local/lib/* /opt/wkhhtml/ 2>/dev/null || true && \
    # 复制共享文件
    cp -r usr/local/share/* /opt/wkhhtml/ 2>/dev/null || true && \
    cp -r usr/share/* /opt/wkhhtml/share/ 2>/dev/null || true && \
    # 创建必要的目录结构
    mkdir -p /opt/wkhhtml/lib && \
    mkdir -p /opt/wkhhtml/share && \
    # 复制依赖的库文件
    cp -r usr/lib/* /opt/wkhhtml/lib/ 2>/dev/null || true && \
    # 清理临时文件
    cd / && rm -rf /tmp/wkhtml



# 设置时区
RUN ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone





# 验证安装的工具版本
RUN echo "=== 验证安装的工具版本 ===" && \
    echo "Java version:" && java -version 2>&1 | head -3 && \
    echo -e "\ncurl version:" && curl --version 2>&1 | head -1 && \
    echo -e "\ngit version:" && git --version && \
    echo -e "\nvim version:" && vim --version 2>&1 | head -1 && \
    echo -e "\nlsof version:" && lsof --version 2>&1 | head -1 && \
    echo -e "\nalien version:" && alien --version 2>&1 && \
    echo -e "\nwkhtmltopdf version:" && /opt/wkhhtml/bin/wkhtmltopdf --version 2>&1 && \
    echo -e "\nLibreOffice version:" && /opt/libreoffice6.3/program/soffice --version 2>&1 && \
    echo -e "\n=== 目录结构验证 ===" && \
    echo "LibreOffice 安装位置:" && ls -la /opt/libreoffice6.3/ && \
    echo -e "\nwkhtmltopdf 安装位置:" && ls -la /opt/wkhhtml/bin/

# 切换回普通用户（如果需要）
# USER appuser



# 默认启动命令
CMD ["bash"]
