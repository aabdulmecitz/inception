FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server mariadb-client

RUN sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mariadb.conf.d/50-server.cnf

RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql

COPY tools/setup.sh /
RUN chmod +x /setup.sh

EXPOSE 3306

CMD ["/setup.sh"]
