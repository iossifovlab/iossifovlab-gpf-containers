ARG REGISTRY=""
ARG BASE_IMAGE_TAG=latest
FROM ${REGISTRY}iossifovlab-gpf:${BASE_IMAGE_TAG}


SHELL ["/bin/bash", "-c"]

RUN DEBIAN_FRONTEND=noninteractive apt-get update --fix-missing && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y \
		supervisor less \
		apache2 mysql-client && \
	DEBIAN_FRONTEND=noninteractive apt-get clean

RUN mkdir -p /logs
RUN mkdir -p /site

COPY gpfjs /site/gpf


WORKDIR /site

# configure wdae
COPY ./wdae/wdae.wsgi /gpf/lib/python3.10/site-packages/wdae/wsgi.py
COPY ./wdae/gunicorn.wsgi /gpf/lib/python3.10/site-packages/wdae/gunicorn_wsgi.py
COPY ./wdae/settings.py /gpf/lib/python3.10/site-packages/wdae/settings.py
COPY ./wdae/gunicorn_settings.py /gpf/lib/python3.10/site-packages/wdae/gunicorn_settings.py
COPY ./wdae/create_oauth_app.py /gpf/lib/python3.10/site-packages/wdae/create_oauth_app.py


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
RUN echo "SetEnv proxy-initial-not-pooled 1" >> /etc/apache2/apache2.conf

RUN rm -f /etc/apache2/sites-enabled/000-default.conf

COPY ./supervisor/supervisord.conf /etc/
COPY ./bin/supervisord-bootstrap.sh /
COPY ./bin/wait-for-it.sh /
RUN chmod +x /*.sh

EXPOSE 80 443

ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf", "-n"]
