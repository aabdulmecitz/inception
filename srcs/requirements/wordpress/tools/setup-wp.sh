#!/bin/bash
set -e

WP_PATH="/var/www/wordpress"
DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(grep "^WP_ADMIN_PASSWORD" /run/secrets/credentials | cut -d= -f2)
WP_USER_PASSWORD=$(grep "^WP_USER_PASSWORD"   /run/secrets/credentials | cut -d= -f2)

# Download WordPress core if it is missing
if [ ! -f "${WP_PATH}/wp-login.php" ]; then
	wp core download --path="${WP_PATH}" --allow-root --locale=en_US
fi

# Create wp-config.php if it does not exist
if [ ! -f "${WP_PATH}/wp-config.php" ]; then
	wp config create \
		--path="${WP_PATH}" \
		--dbname="${MYSQL_DATABASE}" \
		--dbuser="${MYSQL_USER}" \
		--dbpass="${DB_PASSWORD}" \
		--dbhost=mariadb \
		--allow-root
fi

# Wait until MariaDB is reachable on port 3306
until bash -c "</dev/tcp/mariadb/3306" 2>/dev/null; do
	sleep 1
done

# Install WordPress if it has not been installed yet
if ! wp core is-installed --path="${WP_PATH}" --allow-root 2>/dev/null; then

	wp core install \
		--path="${WP_PATH}" \
		--url="https://${DOMAIN_NAME}" \
		--title="${WP_TITLE}" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--skip-email \
		--allow-root

	chown -R www-data:www-data "${WP_PATH}"
fi

# Create the author user if it is missing
if ! wp user get "${WP_USER}" --path="${WP_PATH}" --allow-root 2>/dev/null; then

	wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
		--role=author \
		--user_pass="${WP_USER_PASSWORD}" \
		--path="${WP_PATH}" \
		--allow-root
fi

# Ensure the PHP-FPM runtime directory exists
mkdir -p /run/php

# Run PHP-FPM in the foreground as PID 1
exec php-fpm8.2 -F -R
