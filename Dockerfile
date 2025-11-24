# 不使用国内源，直接下载安装网络工具
FROM crpi-95ycgp634fv97mlw.cn-hangzhou.personal.cr.aliyuncs.com/pengfei-y/dm:hr_4



# 检测操作系统类型并安装工具
RUN if [ -f /etc/alpine-release ]; then \
        echo "检测到 Alpine 系统" && \
        apk update && apk add --no-cache \
            iputils-ping \
            busybox-extras \
            bind-tools \
            htop \
            procps \
            curl \
            wget; \
    elif [ -f /etc/debian_version ]; then \
        echo "检测到 Debian/Ubuntu 系统" && \
        apt-get update && apt-get install -y \
            iputils-ping \
            telnet \
            netcat-openbsd \
            dnsutils \
            htop \
            procps \
            curl \
            wget \
        && rm -rf /var/lib/apt/lists/*; \
    elif [ -f /etc/redhat-release ]; then \
        echo "检测到 CentOS/RHEL 系统" && \
        yum update -y && yum install -y \
            iputils \
            telnet \
            nmap-ncat \
            bind-utils \
            htop \
            procps-ng \
            curl \
            wget \
        && yum clean all; \
    else \
        echo "未知系统，尝试二进制安装" && \
        mkdir -p /opt/tools/bin && \
        wget -O /opt/tools/bin/busybox https://busybox.net/downloads/binaries/1.35.0-aarch64-linux-musl/busybox && \
        chmod +x /opt/tools/bin/busybox && \
        cd /opt/tools/bin && \
        ln -sf busybox ping && \
        ln -sf busybox telnet && \
        ln -sf busybox nc && \
        ln -sf busybox nslookup && \
        ln -sf busybox wget && \
        wget -O /opt/tools/bin/htop https://github.com/htop-dev/htop/releases/download/3.2.2/htop-3.2.2-aarch64-linux-musl && \
        chmod +x /opt/tools/bin/htop; \
    fi

# 验证工具安装
RUN echo "=== 验证工具安装 ===" && \
    which ping && \
    which telnet && \
    which nc && \
    which nslookup && \
    which htop && \
    which top && \
    echo "所有工具安装成功"

# 清理缓存
RUN if [ -f /etc/alpine-release ]; then rm -rf /var/cache/apk/*; \
    elif [ -f /etc/debian_version ]; then apt-get clean; \
    elif [ -f /etc/redhat-release ]; then yum clean all; \
    fi
