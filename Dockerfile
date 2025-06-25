# Container image that runs your code
FROM centos:7

# Copies your code file from your action repository to the filesystem path `/` of the container
RUN sed -i 's|mirrorlist.centos.org|mirrors.aliyun.com|g' /etc/yum.repos.d/CentOS-*.repo && \
    yum clean all && \
    yum -y install curl 

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
