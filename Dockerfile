FROM bitnami/php-fpm:latest
MAINTAINER Zetanova <office@zetanova.eu>


ENV EXTENSION_DIR="/opt/bitnami/php/lib/php/extensions" \
	REDIS_VERSION=3.1.1
	
#INIT
RUN pecl channel-update pecl.php.net \
	&& pecl config-set ext_dir $EXTENSION_DIR
#todo fix set extension_dir of pho-config


#Install redis pecl
#until fix extension_dir of pho-config 
#RUN apt-get install -yqq autoconf build-essential
#RUN pecl install -f redis-3.1.1 

#Install redis source
RUN apt-get update \
	&& apt-get -yqq install autconf wget build-essential
RUN mkdir -p /tmp/php-redis
WORKDIR /tmp/php-redis
RUN wget https://pecl.php.net/get/redis-$REDIS_VERSION.tgz \
	&& tar -xzf redis-$REDIS_VERSION.tgz --strip=1
RUN phpize \
	&& ./configure \
	&& make
#make install
#until fix extension_dir of pho-config 
RUN mv modules/* $EXTENSION_DIR
WORKDIR / 
RUN rm -dR /tmp/php-redis


#Install Newrelic-php
RUN apt-get update \
	&& apt-get -yqq install wget python-setuptools 
RUN easy_install pip
RUN mkdir -p /opt/newrelic
WORKDIR /opt/newrelic
RUN wget -r -nd --no-parent -Alinux.tar.gz \
    http://download.newrelic.com/php_agent/release/ >/dev/null 2>&1 \
    && tar -xzf newrelic-php*.tar.gz --strip=1
ENV NR_INSTALL_SILENT=true
#ENV NR_INSTALL_KEY={{key "NEWRELIC_LICENSE_KEY"}}
RUN bash newrelic-install install
WORKDIR /
#Install newrelic agent
RUN pip install newrelic-plugin-agent
RUN mkdir -p /var/log/newrelic \
	&& mkdir -p /var/run/newrelic

#cleanup
RUN apt-get remove -yqq autoconf wget python-setuptools build-essential

WORKDIR /app/