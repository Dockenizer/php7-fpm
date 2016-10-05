FROM dockenizer/alpine
MAINTAINER Jacques Moati <jacques@moati.net>

ENV IMAGICK_VERSION=3.4.3RC1

RUN apk  --update \
         --repository http://dl-3.alpinelinux.org/alpine/v3.4/main/ \
         --repository http://dl-3.alpinelinux.org/alpine/edge/main/ \
         --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ \
         --repository http://dl-3.alpinelinux.org/alpine/edge/community/ \
         upgrade && \

    apk  \
         --repository http://dl-3.alpinelinux.org/alpine/v3.4/main/ \
         --repository http://dl-3.alpinelinux.org/alpine/edge/main/ \
         --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ \
         --repository http://dl-3.alpinelinux.org/alpine/edge/community/ \
        add icu icu-dev curl libtool imagemagick-dev make g++ autoconf php7-amqp php7-ftp php7-dev php7-fpm php7-gd php7-dom php7-zlib php7-ctype php7-zip php7-sqlite3 php7-xml php7-sockets php7-pcntl php7-openssl php7-mysqlnd php7-phar php7-mcrypt php7-session php7-opcache php7-posix php7-curl php7-gettext php7-json php7-mbstring php7-exif php7-iconv php7-intl php7-bcmath php7-bz2 php7-pdo_mysql perl && \

    cd / && \
    curl https://pecl.php.net/get/imagick-${IMAGICK_VERSION}.tgz | tar zxv && \
    cd imagick-${IMAGICK_VERSION} && \
    phpize7 && \
    ./configure --with-php-config=php-config7 && \
    make && \
    make install && \
    echo "extension=imagick.so" > /etc/php7/conf.d/imagick.ini && \

    sed -i '/daemonize /c daemonize = no' /etc/php7/php-fpm.conf && \
    sed -i '/^user /c user = www-data' /etc/php7/php-fpm.d/www.conf && \
    sed -i '/^group /c group = www-data' /etc/php7/php-fpm.d/www.conf && \
    sed -i '/^listen /c listen = 0.0.0.0:9000' /etc/php7/php-fpm.d/www.conf && \
    sed -i 's/^listen.allowed_clients/;listen.allowed_clients/' /etc/php7/php-fpm.d/www.conf && \

    echo "date.timezone= Europe/Paris" >>  /etc/php7/php.ini && \
    echo "phar.readonly = Off" >> /etc/php7/php.ini && \
    sed -i -e "s/^max_execution_time\s*=.*/max_execution_time = 0/" \
        -e "s/^post_max_size\s*=.*/post_max_size = 10G/" \
        -e "s/^upload_max_filesize\s*=.*/upload_max_filesize = 10G\nupload_max_size = 10G/" \
        -e "s/^memory_limit\s*=.*/memory_limit = -1/" \
        -e "s/^max_input_time\s*=.*/max_input_time = 0/" /etc/php7/php.ini && \

    adduser www-data -h /var/www -D && \
    ln -s /usr/bin/php7 /usr/bin/php && \

    apk del --purge make g++ autoconf libtool php7-dev icu-dev && \
    rm -rf /var/cache/apk/* && \
    rm -rf /imagick-${IMAGICK_VERSION}


COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 9000

CMD /run.sh
