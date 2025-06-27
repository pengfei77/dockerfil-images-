FROM crpi-95ycgp634fv97mlw.cn-hangzhou.personal.cr.aliyuncs.com/pengfei-y/dm:nginx-1.21.6-arm64

# 替换为 CentOS Vault 仓库（适用于 CentOS 8 或已停止维护的版本）
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* && \
RUN yum update -y && \
    yum groupinstall -y "Development Tools" && \
    yum install -y \
    curl wget \
    git \
    vim-enhanced \
    htop \
    net-tools iproute tcpdump \
    lsof \
    jq \
    zip unzip \
    bind-utils iputils \
    tmux \
    nc \
    strace \
    && yum clean all \
    && rm -rf /var/cache/yum
