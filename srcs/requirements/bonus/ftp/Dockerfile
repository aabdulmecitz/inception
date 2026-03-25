FROM debian:bullseye

RUN apt-get update && apt-get install -y vsftpd && \
    rm -rf /var/lib/apt/lists/*

COPY tools/setup_ftp.sh /setup_ftp.sh
RUN chmod +x /setup_ftp.sh

EXPOSE 21

CMD ["/setup_ftp.sh"]
