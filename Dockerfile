# 使用官方 Eclipse Temurin JDK 17 镜像（基于 Ubuntu 22.04）
FROM eclipse-temurin:17-jdk-jammy

# 设置工作目录
WORKDIR /app

# 安装系统工具和 Maven 依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    wget \
    vim \
    net-tools \
    zip \
    unzip \
    iputils-ping \
    netcat-openbsd \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 安装 Maven 3.9.x
ARG MAVEN_VERSION=3.9.6
ARG MAVEN_SHA=f355c3fce5c5a8b68600a9c5aad8dc18e3f9a7b1a3b85a8b1a3a3a8b1a3a8b1a
ARG MAVEN_BASE_URL=https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN mkdir -p /usr/share/maven /usr/share/maven/ref && \
    curl -fsSL -o /tmp/apache-maven.tar.gz ${MAVEN_BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    echo "${MAVEN_SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
    tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
    rm -f /tmp/apache-maven.tar.gz \
    ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

# 配置环境变量
ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "/root/.m2"

# 验证安装
RUN mvn --version \
    && java -version \
    && echo "Installed Tools:" \
    && curl --version \
    && wget --version \
    && vim --version | head -n 1 \
    && ping -V \
    && nc -h

# 默认命令（可覆盖）
CMD ["mvn", "--version"]
