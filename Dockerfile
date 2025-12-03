# Dockerfile.deps - 基础依赖镜像
FROM ubuntu:22.04 AS base

USER root
SHELL ["/bin/bash", "-c"]

ARG NEED_MIRROR=0
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /deps

# 配置APT镜像源
RUN if [ "$NEED_MIRROR" == "1" ]; then \
        sed -i 's|http://ports.ubuntu.com|http://mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list; \
        sed -i 's|http://archive.ubuntu.com|http://mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list; \
    fi; \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache && \
    chmod 1777 /tmp

# 更新并安装系统工具
RUN apt update && \
    apt --no-install-recommends install -y ca-certificates && \
    apt update && \
    apt install -y \
        libglib2.0-0 libglx-mesa0 libgl1 \
        pkg-config libicu-dev libgdiplus \
        default-jdk \
        libatk-bridge2.0-0 \
        libpython3-dev libgtk-4-1 libnss3 xdg-utils libgbm-dev \
        libjemalloc-dev \
        python3-pip pipx nginx unzip curl wget git vim less \
        ghostscript

# 配置Python镜像源和安装uv
RUN if [ "$NEED_MIRROR" == "1" ]; then \
        pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
        pip3 config set global.trusted-host pypi.tuna.tsinghua.edu.cn; \
        mkdir -p /etc/uv && \
        echo "[[index]]" > /etc/uv/uv.toml && \
        echo 'url = "https://pypi.tuna.tsinghua.edu.cn/simple"' >> /etc/uv/uv.toml && \
        echo "default = true" >> /etc/uv/uv.toml; \
    fi; \
    pipx install uv

ENV PATH=/root/.local/bin:$PATH

# 安装Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt purge -y nodejs npm cargo && \
    apt autoremove -y && \
    apt update && \
    apt install -y nodejs

# 安装Rust
RUN apt update && apt install -y curl build-essential \
    && if [ "$NEED_MIRROR" == "1" ]; then \
         export RUSTUP_DIST_SERVER="https://mirrors.tuna.tsinghua.edu.cn/rustup"; \
         export RUSTUP_UPDATE_ROOT="https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup"; \
       fi; \
    curl --proto '=https' --tlsv1.2 --http1.1 -sSf https://sh.rustup.rs | bash -s -- -y --profile minimal \
    && echo 'export PATH="/root/.cargo/bin:${PATH}"' >> /root/.bashrc

ENV PATH="/root/.cargo/bin:${PATH}"

# 安装数据库ODBC驱动
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt update && \
    arch="$(uname -m)"; \
    if [ "$arch" = "arm64" ] || [ "$arch" = "aarch64" ]; then \
        ACCEPT_EULA=Y apt install -y unixodbc-dev msodbcsql18; \
    else \
        ACCEPT_EULA=Y apt install -y unixodbc-dev msodbcsql17; \
    fi

# 下载Chrome和ChromeDriver
RUN wget -O /chrome-linux64.zip "https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/121.0.6167.85/linux64/chrome-linux64.zip" && \
    wget -O /chromedriver-linux64.zip "https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/121.0.6167.85/linux64/chromedriver-linux64.zip"

# 下载Tika服务器
RUN wget -O /tika-server-standard-3.0.0.jar \
    "https://archive.apache.org/dist/tika/3.0.0/tika-server-standard-3.0.0.jar" && \
    wget -O /tika-server-standard-3.0.0.jar.md5 \
    "https://archive.apache.org/dist/tika/3.0.0/tika-server-standard-3.0.0.jar.md5"

# 下载Tokenizer数据
RUN wget -O /cl100k_base.tiktoken \
    "https://openaipublic.blob.core.windows.net/encodings/cl100k_base.tiktoken"

# 下载SSL库
RUN arch="$(uname -m)"; \
    if [ "$arch" = "x86_64" ]; then \
        wget -O /libssl1.1_1.1.1f-1ubuntu2_amd64.deb \
            "http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb"; \
    elif [ "$arch" = "aarch64" ]; then \
        wget -O /libssl1.1_1.1.1f-1ubuntu2_arm64.deb \
            "http://ports.ubuntu.com/ubuntu-ports/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_arm64.deb"; \
    fi

# 创建必要的目录结构
RUN mkdir -p /ragflow/rag/res/deepdoc /root/.ragflow /nltk_data

# 验证安装
RUN echo "=== 安装验证 ===" && \
    java -version && \
    python3 --version && \
    node --version && \
    npm --version && \
    cargo --version && \
    uv --version

# 设置环境变量
ENV PYTHONDONTWRITEBYTECODE=1 \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 \
    TIKA_SERVER_JAR="file:///ragflow/tika-server-standard-3.0.0.jar"

CMD ["/bin/bash"]
