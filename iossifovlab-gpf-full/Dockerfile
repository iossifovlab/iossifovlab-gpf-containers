ARG REGISTRY=""
ARG BASE_IMAGE_TAG=latest
FROM ${REGISTRY}iossifovlab-gpf:${BASE_IMAGE_TAG}


SHELL ["/bin/bash", "-c"]

RUN DEBIAN_FRONTEND=noninteractive apt-get update --fix-missing && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y \
		supervisor less \
		apache2 && \
	DEBIAN_FRONTEND=noninteractive apt-get clean

RUN mkdir -p /logs
RUN mkdir -p /site

COPY gpfjs /site/gpf


WORKDIR /site

# configure wdae
COPY ./wdae/wdae.wsgi /code/wdae/wdae/wdae/wsgi.py
COPY ./wdae/gunicorn.wsgi /code/wdae/wdae/wdae/gunicorn_wsgi.py
COPY ./wdae/settings.py /code/wdae/wdae/wdae/settings.py
COPY ./wdae/gunicorn_settings.py /code/wdae/wdae/wdae/gunicorn_settings.py
COPY ./wdae/create_oauth_app.py /code/wdae/wdae/wdae/create_oauth_app.py

RUN source /gpf/bin/activate && cd /code/wdae/ && pip install .



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

COPY ./supervisor/supervisord.conf /etc/
COPY ./bin/supervisord-bootstrap.sh /
COPY ./bin/wait-for-it.sh /
RUN chmod +x /*.sh

EXPOSE 80 443

# CMD ["/bootstrap.sh"]
# CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf", "-n"]
