FROM --platform=linux/arm64 nginx:1.21.6

RUN apt-get update && \
    apt-get install -y \
        vim \
        telnet \
        iputils-ping \
        curl \
        net-tools \
        dnsutils && \
    rm -rf /var/lib/apt/lists/*
