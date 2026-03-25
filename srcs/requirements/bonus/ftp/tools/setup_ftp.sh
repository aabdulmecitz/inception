#!/bin/bash

# Create user if it doesn't exist
if ! id -u "$FTP_USER" > /dev/null 2>&1; then
    adduser --disabled-password --gecos "" "$FTP_USER"
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
    usermod -aG www-data "$FTP_USER"
fi

# Create vsftpd.conf
cat > /etc/vsftpd.conf << EOF
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
allow_writeable_chroot=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
user_sub_token=\$USER
local_root=/var/www/html
pasv_enable=YES
pasv_min_port=21000
pasv_max_port=21010
pasv_address=127.0.0.1
EOF

mkdir -p /var/run/vsftpd/empty

exec vsftpd /etc/vsftpd.conf
