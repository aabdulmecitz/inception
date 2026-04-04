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
fi

echo "Ensuring database and users..."
INIT_SQL_FILE="/tmp/mariadb-init.sql"

cat > "${INIT_SQL_FILE}" <<-EOSQL
    CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;
    CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';
    ALTER USER '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';
    FLUSH PRIVILEGES;
EOSQL

chown mysql:mysql "${INIT_SQL_FILE}"
chmod 600 "${INIT_SQL_FILE}"

exec /usr/sbin/mariadbd --user=mysql --bind-address=0.0.0.0 --init-file="${INIT_SQL_FILE}"
