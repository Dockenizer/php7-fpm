FROM php:fpm-alpine
MAINTAINER Jacques Moati <jacques@moati.net>

WORKDIR /var/www/

RUN apk --repository http://dl-3.alpinelinux.org/alpine/edge/community/ \
        --repository http://dl-3.alpinelinux.org/alpine/edge/main/ \
        --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ \
        --update \
        add bash shadow openssl icu icu-dev curl libtool imagemagick-dev make g++ autoconf perl rabbitmq-c-dev freetype-dev libjpeg-turbo-dev libmcrypt-dev libpng-dev pcre-dev libxml2-dev && \

    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install iconv mcrypt gd bcmath exif intl opcache pcntl sockets zip pdo_mysql soap  && \
    pecl install imagick amqp redis && \
    docker-php-ext-enable imagick amqp redis && \

    apk del --purge make g++ autoconf libtool && \
    rm -rf /var/cache/apk/*

COPY run.sh /run.sh
RUN chmod +x /run.sh

COPY php.ini /usr/local/etc/php/

EXPOSE 9000

CMD /run.sh
