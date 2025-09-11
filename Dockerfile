FROM crpi-95ycgp634fv97mlw.cn-hangzhou.personal.cr.aliyuncs.com/pengfei-y/dm@sha256:b14f91297393417d7c6736cd6c5967a0b3794531caefecb2c06bc26c9ef7faea

# 切换到 root 用户编译 jemalloc
USER root

RUN cp /opt/bitnami/scripts/redis-sentinel/run.sh /opt/bitnami/scripts/redis-sentinel/run.sh.orig

# 修改 run.sh 添加 LD_PRELOAD
RUN sed -i '/info "\*\* Starting Redis Sentinel \*\*"/i \ \ \ \ export LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libjemalloc.so.2' \
    /opt/bitnami/scripts/redis-sentinel/run.sh

# 验证修改是否成功
RUN grep "LD_PRELOAD" /opt/bitnami/scripts/redis-sentinel/run.sh || echo "修改失败"

# 切换回非 root 用户
USER 1001

# 验证 jemalloc 库是否存在
RUN ls -la /usr/lib/aarch64-linux-gnu/libjemalloc.so.2 || echo "jemalloc 库不存在"
