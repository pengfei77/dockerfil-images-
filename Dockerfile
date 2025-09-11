

FROM crpi-95ycgp634fv97mlw.cn-hangzhou.personal.cr.aliyuncs.com/pengfei-y/dm:hr_2

# 切换到 root 用户
USER root

# 更新源并安装大页兼容的 jemalloc
RUN apt-get update && \
    apt-get install -y libjemalloc2-arm64-largepage && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 验证库文件是否存在
RUN ls -la /usr/lib/aarch64-linux-gnu/libjemalloc-largepage.so.2

# 设置环境变量（可选）
ENV LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libjemalloc-largepage.so.2

# 切换回非 root 用户
USER 1001

