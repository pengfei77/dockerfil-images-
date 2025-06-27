FROM crpi-95ycgp634fv97mlw.cn-hangzhou.personal.cr.aliyuncs.com/pengfei-y/dm:nginx-1.21.6-arm64

# 更新软件包列表并安装工具（使用 apt）
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    vim \
    htop \
    net-tools \       # ifconfig, netstat 等
    iproute2 \        # ip 命令（替代 ifconfig）
    tcpdump \
    lsof \
    jq \
    zip \
    unzip \
    dnsutils \        # dig, nslookup
    iputils-ping \    # ping
    tmux \
    netcat-openbsd \  # nc
    strace \
    && rm -rf /var/lib/apt/lists/*  # 清理缓存减小镜像体积
