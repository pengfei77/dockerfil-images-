# 不使用国内源，直接下载安装网络工具
FROM crpi-95ycgp634fv97mlw.cn-hangzhou.personal.cr.aliyuncs.com/pengfei-y/dm:hr_3
ENV LANG C.UTF-8
ENV TZ Asia/Shanghai
RUN apt-get update && apt-get install -y libreoffice



