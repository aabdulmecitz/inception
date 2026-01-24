#!/bin/bash

# MariaDB Setup Script
# Database and user initialization

echo "MariaDB service is starting..."

# Prepare data directory
if [ ! -d /var/lib/mysql/mysql ]; then
    echo "Database starting for the first time..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    # Execute initialization script
    /usr/sbin/mariadbd --user=mysql --bind-address=0.0.0.0 &
    sleep 3
    
    # Run init.sql file
    if [ -f /docker-entrypoint-initdb.d/init.sql ]; then
        echo "Running SQL script..."
        mysql -u root < /docker-entrypoint-initdb.d/init.sql
    fi
    
    # Stop MariaDB
    pkill mariadbd
    sleep 2
fi

# Start MariaDB server (in foreground mode)
exec /usr/sbin/mariadbd --user=mysql --bind-address=0.0.0.0
