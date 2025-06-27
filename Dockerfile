FROM crpi-95ycgp634fv97mlw.cn-hangzhou.personal.cr.aliyuncs.com/pengfei-y/dm:nginx-1.21.6-arm64

# 替换为 CentOS Vault 仓库（适用于 CentOS 8 或已停止维护的版本）
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* && \
    yum update -y && \
    yum install -y \
    curl \          # HTTP 请求工具
    wget \          # 下载工具
    git \           # 版本控制
    vim-enhanced \  # 增强版 Vim
    htop \          # 进程监控
    net-tools \     # ifconfig, netstat 等网络工具
    tcpdump \       # 网络抓包
    lsof \          # 查看打开的文件和网络连接
    jq \            # JSON 处理工具
    zip \           # 压缩工具
    unzip \         # 解压工具
    bind-utils \    # dig, nslookup 等 DNS 工具
    iputils \       # ping 命令
    tmux \          # 终端复用工具
    && yum clean all
