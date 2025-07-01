# 使用官方 Eclipse Temurin JDK 17 镜像（基于 Ubuntu 22.04）
FROM eclipse-temurin:17-jdk-jammy

# 设置工作目录
WORKDIR /app

# 安装系统工具和 Docker CLI（不安装 Docker 守护进程）
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    wget \
    vim \
    net-tools \
    zip \
    unzip \
    iputils-ping \
    netcat-openbsd \
    # 安装 Docker CLI（客户端工具）
    docker.io \
    && rm -rf /var/lib/apt/lists/*

# 安装 Maven 3.9.x
ARG MAVEN_VERSION=3.9.10
ARG MAVEN_SHA=4ef617e421695192a3e9a53b3530d803baf31f4269b26f9ab6863452d833da5530a4d04ed08c36490ad0f141b55304bceed58dbf44821153d94ae9abf34d0e1b
ARG MAVEN_BASE_URL=https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
    && curl -fsSL -o /tmp/apache-maven.tar.gz ${MAVEN_BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && echo "${MAVEN_SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
    && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
    && rm -f /tmp/apache-maven.tar.gz \
    && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

# 配置环境变量
ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "/root/.m2"

# 验证安装
RUN mvn --version \
    && docker --version \
    && java -version \
    && echo "Installed Tools:" \
    && curl --version \
    && wget --version \
    && vim --version | head -n 1 \
    && ping -V \
    && nc -h

# 默认命令（可覆盖）
CMD ["mvn"]
