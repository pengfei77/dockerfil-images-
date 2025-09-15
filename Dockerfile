FROM python:3.12-slim

# 设置工作目录
WORKDIR /app

# 安装 uv (Rust 编写的快速 Python 包管理器)
RUN pip install --no-cache-dir uv && \
    uv --version
