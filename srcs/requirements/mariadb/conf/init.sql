-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS wordpress;

-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'aozkaya'@'%' IDENTIFIED BY 'gizlisifre';

-- Grant all privileges on the wordpress database to the user
GRANT ALL PRIVILEGES ON wordpress.* TO 'aozkaya'@'%';

-- Flush privileges to apply changes
FLUSH PRIVILEGES;
