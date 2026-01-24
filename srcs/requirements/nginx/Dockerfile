ARG OS_VERSION

FROM debian:${OS_VERSION}

RUN apt-get update && apt-get install -y nginx openssl

RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=TR/ST=Istanbul/L=Istanbul/O=42Istanbul/OU=Student/CN=aozkaya.42.fr"

COPY conf/nginx.conf /etc/nginx/nginx.conf

# Sometimes /var/run/nginx directory will not be created, so we ensure it exists
RUN mkdir -p /var/run/nginx

CMD ["nginx", "-g", "daemon off;"]