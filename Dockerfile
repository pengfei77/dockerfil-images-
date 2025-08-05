# 应用基础镜像
#FROM alpine:3.10
FROM registry.saas.crland.com.cn/tools/alpine:3.10

##########x86 切换arm 架构注意事项#########
# 替换如下包
# COPY tags/apk/x86_64/rdkafka.so  /usr/lib/php7/modules/
# COPY tags/apk/x86_64/igbinary.so  /usr/lib/php7/modules/
# COPY tags/apk/x86_64/redis.so  /usr/lib/php7/modules/
##########x86切换arm 架构注意事项#########

ARG BUILD_DATE
ARG VCS_REF

# PHP_INI_DIR to be symmetrical with official php docker image
#ENV PHP_INI_DIR /etc/php/7.3

# When using Composer, disable the warning about running commands as root/super user
ENV COMPOSER_ALLOW_SUPERUSER=1

ARG DEPSALL="\
        nginx \
        nginx-mod-http-headers-more \
        php7 \
        php7-phar \
        php7-bcmath \
        php7-calendar \
        php7-mbstring \
        php7-exif \
        php7-ftp \
        php7-openssl \
        php7-zip \
        php7-sysvsem \
        php7-sysvshm \
        php7-sysvmsg \
        php7-shmop \
        php7-sockets \
        zlib \
        php7-bz2 \
        php7-curl \
        php7-simplexml \
        php7-xml \
        php7-opcache \
        php7-dom \
        php7-xmlreader \
        php7-xmlwriter \
        php7-tokenizer \
        php7-ctype \
        php7-session \
        php7-fileinfo \
        php7-iconv \
        php7-json \
        php7-posix \
        php7-fpm \
        php7-pdo_mysql \
        php7-gd \
        php7-soap \
        php7-mysqli \
        curl \
        ca-certificates \
        runit \
        supervisor \
        php7-pear \
        librdkafka \
        git \
"
#COPY tags/apk/aarch64 /etc/apk/aarch64/

RUN set -x
RUN echo "https://mirrors.aliyun.com/alpine/v3.10/main" >> /etc/apk/repositories
RUN echo "https://mirrors.aliyun.com/alpine/v3.10/community" >> /etc/apk/repositories
RUN echo "/etc/apk" >> /etc/apk/repositories
RUN cat /etc/apk/repositories
RUN apk add --no-cache $DEPSALL
RUN curl -L -o /usr/local/bin/composer https://getcomposer.org/download/2.8.10/composer.phar
RUN chmod +x /usr/local/bin/composer
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

# 创建 www-data 用户并加入该组
RUN adduser -S www-data -G www-data
# 创建 php-fpm7 目录
RUN mkdir -p /run/php-fpm7
# 设置正确的权限（使用你在 PHP-FPM 配置中指定的用户）
RUN chown -R www-data:www-data /run/php-fpm7
RUN chmod 755 /run/php-fpm7
