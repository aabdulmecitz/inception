ARG OS_VERSION

FROM debian:${OS_VERSION}

RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    php-common \
    php-cli \
    wget \
    curl

RUN mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www/html

RUN mkdir -p /run/php && \
    chown -R www-data:www-data /run/php

COPY conf/my_conf.conf /etc/php/7.4/fpm/php-fpm.conf

COPY tools/setup_wp.sh /
RUN chmod +x /setup_wp.sh

WORKDIR /var/www/html

EXPOSE 9000

CMD ["/setup_wp.sh"]