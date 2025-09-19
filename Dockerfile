FROM --platform=linux/arm64 nginx:1.21.6

RUN apt-get update && \
    apt-get install -y \
        vim \          # vi/vim 编辑器
        telnet \       # telnet 客户端
        iputils-ping \ # ping 命令
        curl \         # curl 工具
        net-tools \    # ifconfig, netstat 等网络工具
        dnsutils && \  # dig, nslookup 等 DNS 工具
    rm -rf /var/lib/apt/lists/*  # 清理缓存
