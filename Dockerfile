FROM crpi-95ycgp634fv97mlw.cn-hangzhou.personal.cr.aliyuncs.com/pengfei-y/dm:nginx-1.21.6-arm64

# 更新并安装工具（Debian/Ubuntu）
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    vim \
    htop \
    net-tools \       # ifconfig/netstat
    tcpdump \         # 网络抓包
    lsof \            # 查看打开的文件
    jq \              # JSON处理
    zip \
    unzip \
    dnsutils \        # dig/nslookup
    iputils-ping \    # ping
    tmux \
    netcat-openbsd \  # nc
    strace \
    && rm -rf /var/lib/apt/lists/*
