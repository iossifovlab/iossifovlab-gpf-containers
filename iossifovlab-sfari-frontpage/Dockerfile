ARG REGISTRY=""
ARG BASE_IMAGE_TAG=latest
FROM ${REGISTRY}iossifovlab-http:${BASE_IMAGE_TAG}

SHELL ["/bin/bash", "-c"]

RUN DEBIAN_FRONTEND=noninteractive apt-get update --fix-missing && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y \
		less apache2 && \
	DEBIAN_FRONTEND=noninteractive apt-get clean

RUN mkdir -p /logs
RUN mkdir -p /site

COPY sfari-frontpage /site/frontpage

WORKDIR /site

# configure apache2
RUN mkdir -p /var/run/apache2

ENV APACHE_LOG_DIR=/var/log/apache2
ENV APACHE_LOCK_DIR=/var/lock/apache2
ENV APACHE_RUN_GROUP=www-data
ENV APACHE_RUN_DIR=/var/run/apache2
ENV APACHE_RUN_USER=www-data
ENV APACHE_PID_FILE=/var/run/apache2/apache2.pid

COPY ./sites-available/localhost.conf /etc/apache2/sites-available/

RUN cat /etc/hostname | awk '{print "ServerName "$1}' >> /etc/apache2/apache2.conf

RUN rm -f /etc/apache2/sites-enabled/000-default.conf

EXPOSE 80 443
