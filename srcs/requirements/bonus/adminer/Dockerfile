FROM debian:bullseye

RUN apt-get update && apt-get install -y wget php php-mysql && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html/adminer

RUN wget "https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php" -O /var/www/html/adminer/index.php

WORKDIR /var/www/html/adminer

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080"]
