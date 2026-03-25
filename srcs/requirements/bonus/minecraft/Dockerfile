FROM debian:bullseye

RUN apt-get update && apt-get install -y default-jre wget && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /server

COPY tools/setup_mc.sh /setup_mc.sh
RUN chmod +x /setup_mc.sh

WORKDIR /server

EXPOSE 25565

CMD ["/setup_mc.sh"]
