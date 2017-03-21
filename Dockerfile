FROM bitnami/php-fpm:latest
MAINTAINER Zetanova <office@zetanova.eu>


ENV REDIS_VERSION=3.1.1 \
	EXTENSION_DIR="/opt/bitnami/php/lib/php/extensions" \
	DEBIAN_FRONTEND noninteractive
	
#INIT
RUN pecl channel-update pecl.php.net \
	&& pecl config-set ext_dir $EXTENSION_DIR \
	&& pear config-set ext_dir $EXTENSION_DIR
#todo fix set extension_dir of pho-config

#Install redis pecl
#until fix extension_dir of pho-config 
#RUN apt-get install -yqq autoconf build-essential
#RUN pecl install -f redis-3.1.1 

#Install redis source
RUN apt-get update \
	&& apt-get -yqq install autoconf wget build-essential \
	&& mkdir -p /tmp/php-redis \
	&& cd /tmp/php-redis \
	&& wget https://pecl.php.net/get/redis-$REDIS_VERSION.tgz \
	&& tar -xzf redis-$REDIS_VERSION.tgz --strip=1 \
	&& phpize \
	&& ./configure \
	&& make \
	&& mv modules/* $EXTENSION_DIR \
	&& cd / \
	&& rm -dR /tmp/php-redis \
	&& apt-get remove -yqq autoconf wget build-essential \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#Install Newrelic-php
ENV NR_INSTALL_SILENT=true
#ENV NR_INSTALL_KEY={{key "NEWRELIC_LICENSE_KEY"}}
RUN apt-get update \
	&& apt-get -yqq install wget python-setuptools \
	&& easy_install pip\
	&& mkdir -p /opt/newrelic\
	&& cd /opt/newrelic\
	&& wget -r -nd --no-parent -Alinux.tar.gz \
		http://download.newrelic.com/php_agent/release/ >/dev/null 2>&1 \
    && tar -xzf newrelic-php*.tar.gz --strip=1 \
    && bash newrelic-install install \
    && cp /opt/newrelic/agent/x64/newrelic-20160303.so $EXTENSION_DIR/newrelic.so \
	&& rm -dR /opt/newrelic/agent \
	&& rm newrelic-php*.gz\
	&& cd / \
	&& pip install newrelic-plugin-agent \
	&& mkdir -p /var/log/newrelic \
	&& mkdir -p /var/run/newrelic\
	&& apt-get remove -yqq wget python-setuptools \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
	

#cleanup
RUN apt-get remove -yqq autoconf wget python-setuptools build-essential \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
	
ENV DEBIAN_FRONTEND teletype

WORKDIR /app/