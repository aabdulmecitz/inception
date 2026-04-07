#!/bin/bash
set -e

MYSQL_ROOT_PWD=$(cat /run/secrets/db_root_password)
MYSQL_PWD=$(cat /run/secrets/db_password)

# Ensure the socket directory exists
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Initialize only once, using a sentinel file for restarts
if [ ! -f "/var/lib/mysql/.initialized" ]; then

	mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

	# Start MariaDB temporarily on the local socket
	mysqld --user=mysql --skip-networking &
	TEMP_PID=$!

	# Wait until MariaDB is ready
	until mysqladmin ping --silent; do
		sleep 1
	done

	# Set credentials and create the application database
	mysql -u root <<-EOF
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PWD}';
		CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
		CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PWD}';
		GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
		FLUSH PRIVILEGES;
	EOF

	# Stop the temporary instance cleanly
	mysqladmin -u root -p"${MYSQL_ROOT_PWD}" shutdown
	wait $TEMP_PID

	# Mark initialization as complete
	touch /var/lib/mysql/.initialized
fi

# Run MariaDB in the foreground as PID 1
exec mysqld --user=mysql
