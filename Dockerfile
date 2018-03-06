FROM bitnami/php-fpm:latest as builder
MAINTAINER Zetanova <office@zetanova.eu>

ENV EXTENSION_DIR="/opt/bitnami/php/lib/php/extensions"
	
#INIT
RUN pecl channel-update pecl.php.net

#RUN pecl config-set ext_dir $EXTENSION_DIR \
#	&& pear config-set ext_dir $EXTENSION_DIR
#todo fix set extension_dir of pho-config

RUN pecl install \
	igbinary \
	redis
	
FROM bitnami/php-fpm:latest

COPY --from=builder \
    /opt/bitnami/php/lib/php/extensions/igbinary.so \
    /opt/bitnami/php/lib/php/extensions/redis.so \
	/opt/bitnami/php/lib/php/extensions/

ENV PHP_INI_SCAN_DIR /opt/bitnami/php/lib/php.d

WORKDIR /app/