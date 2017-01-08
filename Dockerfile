FROM resin/rpi-raspbian:jessie

ENV DEBIAN_FRONTEND noninteractive
ENV POSTGRESQLTMPROOT temprootpass

# Update and upgrade
RUN apt-get update
RUN apt-get -y upgrade

# Install Apache
RUN apt-get -y install apache2

# Install PostgreSQL
RUN apt-get install -y libpq-dev postgresql-9.4

RUN apt-get clean

RUN cp /etc/ssl/private/ssl-cert-snakeoil.key /var/lib/postgresql/9.4/main/server.key && \
        chown postgres:postgres /var/lib/postgresql/9.4/main/server.key && \
            chmod 740 /var/lib/postgresql/9.4/main/server.key
RUN mkdir -p /var/run/postgresql/9.4-main.pg_stat_tmp
RUN chown -R postgres:postgres /var/run/postgresql/9.4-main.pg_stat_tmp

ADD install.sh /home/diaspora/install.sh
ADD install_diaspora.sh /home/diaspora/install_diaspora.sh
ADD start.sh /home/diaspora/start.sh

ONBUILD ADD database.yml  /home/diaspora/diaspora/config/database.yml
ONBUILD ADD diaspora.yml  /home/diaspora/diaspora/config/diaspora.yml
ONBUILD ADD diaspora.crt  /home/diaspora/diaspora.crt
ONBUILD ADD diaspora.key  /home/diaspora/diaspora.key
ONBUILD RUN /home/diaspora/install.sh

ONBUILD ADD diaspora.conf /etc/apache2/sites-enabled/000-default.conf
ONBUILD RUN a2enmod ssl proxy proxy_balancer proxy_http headers rewrite lbmethod_byrequests slotmem_shm

ONBUILD EXPOSE 80
ONBUILD EXPOSE 443
ONBUILD CMD ["/bin/bash", "/home/diaspora/start.sh"] 
