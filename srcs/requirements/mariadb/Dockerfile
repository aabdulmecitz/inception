ARG OS_VERSION

FROM debian:${OS_VERSION}
RUN apt-get update && apt-get install -y mariadb-server mariadb-client

RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql

COPY conf/init.sql /docker-entrypoint-initdb.d/

COPY tools/setup.sh /
RUN chmod +x /setup.sh

EXPOSE 3306

CMD ["/setup.sh"]