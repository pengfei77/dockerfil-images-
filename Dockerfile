FROM ubuntu:24.04

RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.aliyun.com@g' /etc/apt/sources.list.d/ubuntu.sources &&\
    sed -i 's@//security.ubuntu.com@//mirrors.aliyun.com@g' /etc/apt/sources.list.d/ubuntu.sources &&\
    sed -i 's@//ports.ubuntu.com@//mirrors.aliyun.com@g' /etc/apt/sources.list.d/ubuntu.sources &&\
	apt-get update &&\
    export DEBIAN_FRONTEND=noninteractive &&\
	apt-get install -y --no-install-recommends tzdata locales xfonts-utils fontconfig libreoffice-nogui &&\
    echo 'Asia/Shanghai' > /etc/timezone &&\
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&\
    localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8 &&\
    locale-gen zh_CN.UTF-8 &&\
    apt-get install -y --no-install-recommends ttf-mscorefonts-installer &&\
    apt-get install -y --no-install-recommends ttf-wqy-microhei ttf-wqy-zenhei xfonts-wqy &&\
	apt-get autoremove -y &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

RUN wget http://maven.saas.crland.com.cn/nexus/repository/static-files/openjdk/jdk8u44/jdk8u282-b08.tar  && \
    tar -zxf jdk8u282-b08.tar && mv jdk8u282-b08 /usr/local/ && rm -rf /usr/local/jdk1.8.0_251 && rm -rf jdk8u282-b08.tar  \
    ls -al /usr/local/jdk8u282-b08

ENV JAVA_HOME /usr/local/jdk8u282-b08
ENV CLASSPATH $JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
ENV PATH $PATH:$JAVA_HOME/bin

RUN java -version

ENV LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8
