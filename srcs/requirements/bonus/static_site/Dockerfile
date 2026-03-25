FROM debian:bullseye

RUN apt-get update && apt-get install -y python3 && \
    rm -rf /var/lib/apt/lists/*

COPY tools/website /var/www/html

WORKDIR /var/www/html

EXPOSE 80

CMD ["python3", "-m", "http.server", "80"]
