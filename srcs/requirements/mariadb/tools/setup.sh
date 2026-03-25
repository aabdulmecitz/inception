#!/bin/bash

set -e

echo "MariaDB service is starting..."

: "${SQL_DATABASE:?SQL_DATABASE is required}"
: "${SQL_USER:?SQL_USER is required}"
: "${SQL_PASSWORD:?SQL_PASSWORD is required}"
: "${SQL_ROOT_PASSWORD:?SQL_ROOT_PASSWORD is required}"

if [ ! -d /var/lib/mysql/mysql ]; then
    echo "Database starting for the first time..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
    DB_WAS_INITIALIZED=true
else
    DB_WAS_INITIALIZED=false
fi

/usr/sbin/mariadbd --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &

echo "Waiting for temporary MariaDB startup..."
until mariadb-admin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
    sleep 1
done

if mariadb --socket=/run/mysqld/mysqld.sock -u root -e "SELECT 1" >/dev/null 2>&1; then
    ROOT_AUTH=""
elif mariadb --socket=/run/mysqld/mysqld.sock -u root -p"${SQL_ROOT_PASSWORD}" -e "SELECT 1" >/dev/null 2>&1; then
    ROOT_AUTH="-p${SQL_ROOT_PASSWORD}"
else
    echo "Cannot authenticate as MariaDB root user with current environment password."
    if [ "$DB_WAS_INITIALIZED" = false ]; then
        echo "Existing data detected, skipping bootstrap SQL and starting MariaDB normally."
        mariadb-admin --socket=/run/mysqld/mysqld.sock shutdown || true
        exec /usr/sbin/mariadbd --user=mysql --bind-address=0.0.0.0
    fi
    exit 1
fi

echo "Ensuring database and users..."
mariadb --socket=/run/mysqld/mysqld.sock -u root ${ROOT_AUTH} <<-EOSQL
    CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;
    CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';
    ALTER USER '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';
    FLUSH PRIVILEGES;
EOSQL

mariadb-admin --socket=/run/mysqld/mysqld.sock -u root -p"${SQL_ROOT_PASSWORD}" shutdown

exec /usr/sbin/mariadbd --user=mysql --bind-address=0.0.0.0
