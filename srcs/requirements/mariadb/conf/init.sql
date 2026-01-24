-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS wordpress_db;

-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'wp_user'@'%' IDENTIFIED BY 'wp_password123';

-- Grant all privileges on the wordpress database to the user
GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wp_user'@'%';

-- Flush privileges to apply changes
FLUSH PRIVILEGES;
