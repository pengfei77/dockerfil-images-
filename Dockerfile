FROM crpi-95ycgp634fv97mlw.cn-hangzhou.personal.cr.aliyuncs.com/pengfei-y/dm:hr_3


# 设置时区（避免apt安装时交互提示）
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 安装工具：
# - curl: 网络请求工具
# - net-tools: 提供 ifconfig
# - wget: 文件下载工具
# - htop: 进程监控工具
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        net-tools \
        wget \
        htop && \
    rm -rf /var/lib/apt/lists/*

# 验证工具是否安装成功（可选）
RUN echo "Installed versions:" && \
    curl --version && \
    ifconfig --version && \
    wget --version && \
    htop --version
