FROM ubuntu:22.04-arm64v8

# 安装wget
RUN apt-get update && \
    apt-get -y upgrade  && \
    apt-get -y install wget
#OpenGL依赖库
RUN apt install libgl1-mesa-glx -y
RUN apt-get install libfontconfig -y
# OpenGL依赖字体
RUN apt install fonts-dejavu -y
RUN apt install fontconfig -y
# curl命令
RUN apt install curl -y

# 下载并解压JDK包
RUN mkdir -p /usr/lib/jvm && \
    cd /usr/lib/jvm && \
    wget https://corretto.aws/downloads/resources/17.0.9.8.1/amazon-corretto-17.0.9.8.1-linux-aarch64.tar.gz && \
    tar -xzvf amazon-corretto-17.0.9.8.1-linux-aarch64.tar.gz && \
    rm amazon-corretto-17.0.9.8.1-linux-aarch64.tar.gz

# 配置 Java 环境变量
ENV JAVA_HOME /usr/lib/jvm/amazon-corretto-17.0.9.8.1-linux-aarch64
ENV PATH=$PATH:$JAVA_HOME/bin
