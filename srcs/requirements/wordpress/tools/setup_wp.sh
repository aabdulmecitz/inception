#!/bin/bash

set -e

: "${SQL_HOST:?SQL_HOST is required}"
: "${SQL_DATABASE:?SQL_DATABASE is required}"
: "${SQL_USER:?SQL_USER is required}"
: "${SQL_PASSWORD:?SQL_PASSWORD is required}"
: "${DOMAIN_NAME:?DOMAIN_NAME is required}"
: "${SITE_TITLE:?SITE_TITLE is required}"
: "${WP_ADMIN_USER:?WP_ADMIN_USER is required}"
: "${WP_ADMIN_PASSWORD:?WP_ADMIN_PASSWORD is required}"
: "${WP_ADMIN_EMAIL:?WP_ADMIN_EMAIL is required}"
: "${WP_USER:?WP_USER is required}"
: "${WP_PASSWORD:?WP_PASSWORD is required}"
: "${WP_EMAIL:?WP_EMAIL is required}"

if echo "${WP_ADMIN_USER}" | grep -Eiq 'admin'; then
    echo "Error: WP_ADMIN_USER must not contain 'admin' or 'administrator'."
    exit 1
fi

# Wait until MariaDB accepts connections.
while ! mariadb -h"${SQL_HOST}" -u"${SQL_USER}" -p"${SQL_PASSWORD}" "${SQL_DATABASE}" -e "SELECT 1" &>/dev/null; do
    echo "Waiting for MariaDB..."
    sleep 3
done

echo "MariaDB connection successful!"

# If wp-config.php exists, WordPress configuration is already in place.
if [ ! -f ./wp-config.php ]; then
    echo "Starting WordPress setup..."

    wp core download --allow-root

    wp config create \
        --dbname="${SQL_DATABASE}" \
        --dbuser="${SQL_USER}" \
        --dbpass="${SQL_PASSWORD}" \
        --dbhost="${SQL_HOST}" \
        --allow-root
fi

if wp core is-installed --allow-root; then
    echo "WordPress is already installed."
else
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="${SITE_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root

    if ! wp user get "${WP_USER}" --field=user_login --allow-root >/dev/null 2>&1; then
        wp user create \
            "${WP_USER}" \
            "${WP_EMAIL}" \
            --role=author \
            --user_pass="${WP_PASSWORD}" \
            --allow-root
    fi

    echo "WordPress setup completed!"
fi

exec /usr/sbin/php-fpm8.2 -F
