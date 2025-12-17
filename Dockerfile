FROM node:18.20.4-alpine3.19


RUN npm install -g npm@7.24.2


RUN npm cache clean --force && \
    rm -rf /tmp/* /var/tmp/*

RUN apk add --no-cache --update \
    curl \
    wget \
    busybox-extras \ 
    bind-tools \
    unzip

EXPOSE 3000
CMD ["node"]
