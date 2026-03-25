FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx openssl gettext-base

COPY conf/nginx.conf.template /etc/nginx/nginx.conf.template
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

# Sometimes /var/run/nginx directory will not be created, so we ensure it exists
RUN mkdir -p /var/run/nginx

CMD ["/setup.sh"]
