FROM amd64/ubuntu:24.04

SHELL ["/bin/bash", "-c"]

RUN DEBIAN_FRONTEND=noninteractive apt-get update --fix-missing && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y \
		supervisor less curl wget \
		apache2 && \
	DEBIAN_FRONTEND=noninteractive apt-get clean


ARG VERSION_TAG

RUN mkdir -p /var/run/apache2

ENV APACHE_LOG_DIR=/var/log/apache2
ENV APACHE_LOCK_DIR=/var/lock/apache2
ENV APACHE_RUN_GROUP=www-data
ENV APACHE_RUN_DIR=/var/run/apache2
ENV APACHE_RUN_USER=www-data
ENV APACHE_PID_FILE=/var/run/apache2/apache2.pid

RUN a2enmod headers ssl

RUN cat /etc/hostname | awk '{print "ServerName "$1}' >> /etc/apache2/apache2.conf
RUN echo "SetEnv proxy-initial-not-pooled 1" >> /etc/apache2/apache2.conf
RUN rm /etc/apache2/sites-enabled/000-default.conf

ADD ./supervisor/supervisord.conf /etc/
ADD ./bin/supervisord-bootstrap.sh /
ADD ./bin/supervisord-bootstrap.sh.d /supervisord-bootstrap.sh.d/
ADD ./bin/wait-for-it.sh /
RUN chmod +x /*.sh

EXPOSE 80 443

ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf", "-n"]

