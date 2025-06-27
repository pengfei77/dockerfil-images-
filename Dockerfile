FROM crpi-95ycgp634fv97mlw.cn-hangzhou.personal.cr.aliyuncs.com/pengfei-y/dm:nginx-1.21.6-arm64

# 先确认系统类型（调试用，正式构建可删除）
RUN cat /etc/os-release

# 如果是 CentOS 才修改仓库（其他系统跳过）
RUN if [ -f /etc/redhat-release ]; then \
    sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*; \
    fi

# 统一安装命令（确保只有一个 RUN）
RUN if [ -f /etc/redhat-release ]; then \
    yum update -y && \
    yum groupinstall -y "Development Tools" && \
    yum install -y \
    curl wget git vim-enhanced htop \
    net-tools iproute tcpdump lsof jq \
    zip unzip bind-utils iputils tmux nc strace \
    && yum clean all \
    && rm -rf /var/cache/yum; \
    fi
