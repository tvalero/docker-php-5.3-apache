FROM ubuntu:14.04
MAINTAINER Kirnos Nikolay <nkirnos@gmail.com>
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y curl wget software-properties-common python-software-properties make
RUN rm -rf /var/lib/apt/lists/* 
RUN  apt-get update && \
    apt-get install -y libfcgi-dev libfcgi0ldbl libjpeg62-dbg libmcrypt-dev libssl-dev libbz2-dev libjpeg-dev \
    libfreetype6-dev libpng12-dev libxpm-dev libxml2-dev libpcre3-dev libbz2-dev libcurl4-openssl-dev \
    libjpeg-dev libpng12-dev libxpm-dev libfreetype6-dev libmysqlclient-dev libt1-dev libgd2-xpm-dev \
    libgmp-dev libsasl2-dev libmhash-dev unixodbc-dev freetds-dev libpspell-dev libsnmp-dev libtidy-dev \
    libxslt1-dev libmcrypt-dev libdb5.3-dev automake libtool m4 git  libc-client* libpq5 libpq-dev && \
    wget -O /var/tmp/php-5.3.29.tar.bz2 http://fr.php.net/get/php-5.3.29.tar.bz2/from/this/mirror && \
    mkdir -p /opt/build && \
    tar jxf /var/tmp/php-5.3.29.tar.bz2 -C /opt/build
WORKDIR /opt/build/php-5.3.29
RUN mkdir /usr/include/freetype2/freetype && \
    ln -s /usr/include/freetype2/freetype.h /usr/include/freetype2/freetype/freetype.h 
    
RUN ./configure --help

RUN     ./configure \
    --enable-fpm \
    --with-mcrypt \
    --enable-mbstring \
    --with-openssl \
    --with-mysql \
    --with-mysql-sock \
    --with-pgsql \
    --with-gd \
    --enable-soap \
    --with-jpeg-dir=/usr/lib \
    --enable-gd-native-ttf  \
    --with-pdo-mysql \
    --with-pdo-pgsql \
    --with-libxml-dir=/usr/lib \
    --with-mysqli=/usr/bin/mysql_config \
    --with-curl \
    --enable-zip  \
    --enable-sockets \
    --with-zlib \
    --enable-exif \
    --enable-ftp \
    --with-iconv \
    --with-bz2 \
    --with-gettext \
    --with-kerberos \
    --with-imap \
    --with-imap-ssl \
    --enable-gd-native-ttf \
    --with-t1lib=/usr \
    --with-freetype-dir=/usr \
    --prefix=/etc/php5 \
    --with-config-file-path=/etc/php5/etc \
    --with-fpm-user=www-data \
    --with-fpm-group=www-data \
    --enable-zend-multibyte \
    --with-pear=/etc/php5/lib/php  && \
    make && make install 
RUN \
    cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm && \
    chmod +x /etc/init.d/php-fpm && \
    mv /etc/php5/etc/php-fpm.conf.default /etc/php5/etc/php-fpm.conf && \
    cp /opt/build/php-5.3.29/php.ini-production /etc/php5/etc/php.ini && \
    ln -s /etc/php5/bin/pear  /usr/bin/pear && \
    ln -s /etc/php5/bin/peardev /usr/bin/peardev && \
    ln -s /etc/php5/bin/pecl /usr/bin/pecl && \
    ln -s /etc/php5/bin/phar /usr/bin/phar && \
    ln -s /etc/php5/bin/phar.phar /usr/bin/phar.phar && \
    ln -s /etc/php5/bin/php /usr/bin/php && \
    ln -s /etc/php5/bin/php-config /usr/bin/php-config && \
    ln -s /etc/php5/bin/phpize /usr/bin/phpize && \
    printf "\n" | pecl install memcache && \
    printf "\n" | pecl install timezonedb && \
    head -n 937 /opt/build/php-5.3.29/php.ini-production > /etc/php5/etc/php.ini && \
    echo 'extension=memcache.so' >> /etc/php5/etc/php.ini && \
    echo 'extension=timezonedb.so' >> /etc/php5/etc/php.ini && \
    tail -n+1000 /opt/build/php-5.3.29/php.ini-production >> /etc/php5/etc/php.ini && \
    echo 'detect_unicode = Off' >> /etc/php5/etc/php.ini
RUN \
    sed -i 's/max_input_time = 30/max_input_time = 60/g' /etc/php5/etc/php.ini && \
    sed -i 's/max_execution_time = 30/max_execution_time = 60/g' /etc/php5/etc/php.ini && \
    sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php5/etc/php.ini && \
    sed -i 's/post_max_size = 8M/post_max_size = 16M/g' /etc/php5/etc/php.ini && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 16M/g' /etc/php5/etc/php.ini && \
    sed -i 's@;date.timezone =@date.timezone = "Europe/Moscow"@g' /etc/php5/etc/php.ini && \
    sed -i 's/pm.max_children = 5/pm.max_children = 8/g' /etc/php5/etc/php-fpm.conf && \
    sed -i 's@;pm.status_path = /status@pm.status_path = /fpm-status@g' /etc/php5/etc/php-fpm.conf && \
    sed -i 's@;ping.path = /ping@ping.path = /fpm-ping@g' /etc/php5/etc/php-fpm.conf && \
    sed -i 's@127.0.0.1:9000@0.0.0.0:9000@g' /etc/php5/etc/php-fpm.conf && \
    update-rc.d php-fpm defaults
# Define working directory.
WORKDIR /
RUN echo '#!/bin/bash' > /init.sh && \
    echo 'service php-fpm start' >> /init.sh && \
    echo 'tail -f /etc/php5/var/log/php-fpm.log' >> /init.sh && \
    chmod +x /init.sh
# Define default command.
CMD ["/init.sh"]
# Expose ports.
EXPOSE 9000