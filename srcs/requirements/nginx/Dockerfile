FROM debian:bookworm

RUN apt-get update && apt-get install -y \
		nginx \
		openssl \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl \
	&& openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/nginx/ssl/cert.key \
		-out    /etc/nginx/ssl/cert.crt \
		-subj   "/C=TR/ST=Istanbul/L=Istanbul/O=42/CN=aozkaya.42.fr"

COPY conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

ENTRYPOINT ["nginx", "-g", "daemon off;"]
