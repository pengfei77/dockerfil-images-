# Container image that runs your code
FROM centos:8

# Copies your code file from your action repository to the filesystem path `/` of the container
RUN yum update && \
    yum clean all && \
    yum -y install curl \
    yum -y install wget

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
