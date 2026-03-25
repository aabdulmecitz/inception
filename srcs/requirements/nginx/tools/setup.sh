#!/bin/bash

set -e

: "${DOMAIN_NAME:?DOMAIN_NAME is required}"
: "${SSL_COUNTRY:=TR}"
: "${SSL_STATE:=Istanbul}"
: "${SSL_LOCALITY:=Istanbul}"
: "${SSL_ORG:=42Istanbul}"
: "${SSL_OU:=Student}"

mkdir -p /etc/nginx/ssl /var/run/nginx

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=${SSL_COUNTRY}/ST=${SSL_STATE}/L=${SSL_LOCALITY}/O=${SSL_ORG}/OU=${SSL_OU}/CN=${DOMAIN_NAME}"

envsubst '${DOMAIN_NAME}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

exec nginx -g "daemon off;"
