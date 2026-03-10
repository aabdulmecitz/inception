FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    mariadb-client \
    curl

# --- WP-CLI KURULUMU (BURAYI EKLE) ---
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp
# ------------------------------------

RUN mkdir -p /var/www/html /run/php && \
    chown -R www-data:www-data /var/www/html /run/php

# PHP-FPM should listen on TCP for NGINX container access
RUN sed -i 's|^listen = .*|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf && \
    sed -i 's|^;clear_env = no|clear_env = no|' /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/setup_wp.sh /
RUN chmod +x /setup_wp.sh

WORKDIR /var/www/html
EXPOSE 9000
ENTRYPOINT ["/setup_wp.sh"]
