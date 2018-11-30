FROM buildpack-deps:jessie
MAINTAINER Eugene Ware <eugene@noblesamurai.com>

RUN apt-get update && apt-get install -y curl && rm -r /var/lib/apt/lists/*

##<apache2>##
RUN apt-get update && apt-get install -y apache2-bin apache2-dev apache2.2-common --no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN rm -rf /var/www/html && mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html && chown -R www-data:www-data /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html

# Apache + PHP requires preforking Apache for best results
RUN a2dismod mpm_event && a2enmod mpm_prefork

RUN mv /etc/apache2/apache2.conf /etc/apache2/apache2.conf.dist
COPY apache2.conf /etc/apache2/apache2.conf
##</apache2>##

#RUN gpg --keyserver pgp.mit.edu --recv-keys 0B96609E270F565C13292B24C13C70B87267B52D 0A95E9A026542D53835E3F3A7DEC4E69FC9C83D7

#ENV GPG_KEYS 0B96609E270F565C13292B24C13C70B87267B52D 0A95E9A026542D53835E3F3A7DEC4E69FC9C83D7 0E604491
#RUN set -xe \
#  && for key in $GPG_KEYS; do \
#    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
#  done

ENV PHP_VERSION 5.3.29

ENV PHP_INI_DIR /usr/local/lib
RUN mkdir -p $PHP_INI_DIR/conf.d

# php 5.3 needs older autoconf
RUN set -x \
	&& apt-get update && apt-get install -y autoconf2.13 && rm -r /var/lib/apt/lists/* \
	&& curl -SLO http://launchpadlibrarian.net/140087283/libbison-dev_2.7.1.dfsg-1_amd64.deb \
	&& curl -SLO http://launchpadlibrarian.net/140087282/bison_2.7.1.dfsg-1_amd64.deb \
	&& dpkg -i libbison-dev_2.7.1.dfsg-1_amd64.deb \
	&& dpkg -i bison_2.7.1.dfsg-1_amd64.deb \
	&& rm *.deb \
	&& curl -SL "http://php.net/get/php-$PHP_VERSION.tar.bz2/from/this/mirror" -o php.tar.bz2 \
	&& curl -SL "http://php.net/get/php-$PHP_VERSION.tar.bz2.asc/from/this/mirror" -o php.tar.bz2.asc \
#	&& gpg --verify php.tar.bz2.asc \
	&& mkdir -p /usr/src/php \
	&& tar -xf php.tar.bz2 -C /usr/src/php --strip-components=1 \
	&& rm php.tar.bz2* \
  && cd /usr/src/php \
  && ./buildconf --force \
	&& ./configure --disable-cgi \
		$(command -v apxs2 > /dev/null 2>&1 && echo '--with-apxs2' || true) \
    --with-config-file-path="$PHP_INI_DIR" \
    --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
		--with-pgsql \
		--with-pdo_pgsql \
        --with-curl  \
    && make -j"$(nproc)" \
	&& make install \
	&& dpkg -r bison libbison-dev \
	&& apt-get purge -y --auto-remove autoconf2.13 \
  && make clean 

COPY install-bin/docker-php-* /usr/local/bin/
COPY install-bin/apache2-foreground /usr/local/bin/

WORKDIR /var/www/html

EXPOSE 80
CMD ["apache2-foreground"]

ENV ALBO_VERSION  2018-11-20

LABEL version             ${ALBO_VERSION}
LABEL vendor              MIVEGEC
LABEL url                 http://www.signalement-moustique.fr/
LABEL vcs-type            git
LABEL vcs-url             https://github.com/tvalero/docker-php-5.3-apache.git
LABEL vcs-ref             ${ALBO_VERSION}
LABEL distribution-scope  private
