# Container image that runs your code
FROM centos:7

# Copies your code file from your action repository to the filesystem path `/` of the container
RUN yum -y install curl 

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
