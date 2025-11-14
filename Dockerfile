FROM centos:8 --platform=linux/arm64
RUN set -eu; \
    # 解决 CentOS 8 源失效问题
    sed -i 's|^mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/CentOS-Linux-* && \
    sed -i 's|^#baseurl=http://mirror.centos.org/$contentdir/$releasever|baseurl=https://mirrors.aliyun.com/centos-vault/8.5.2111|g' /etc/yum.repos.d/CentOS-Linux-* && \
#    # 安装必要依赖
    dnf install -y --nogpgcheck libatomic tar gzip procps libstdc++ openssl ca-certificates curl
