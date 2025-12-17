FROM node:20-alpine3.19


RUN npm install -g npm@9


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
