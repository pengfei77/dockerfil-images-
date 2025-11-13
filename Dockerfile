FROM  swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/library/python:3.10-linuxarm64
# 设置工作目录
WORKDIR /app

RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
    pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn && \
    pip config set global.timeout 120 && \
    pip config set install.retries 5

# 安装系统依赖和ansible
RUN apt-get update && apt-get install -y \
    openssh-client \
    sshpass \
    iputils-ping \
    telnet \
    netcat-openbsd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 复制requirements.txt并安装Python依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 强制安装指定版本的ansible (覆盖requirements.txt中的版本)
RUN pip uninstall -y ansible ansible-core && pip install ansible==2.9.21
