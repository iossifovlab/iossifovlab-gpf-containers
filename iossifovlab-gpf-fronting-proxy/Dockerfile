ARG REGISTRY=""
ARG BASE_IMAGE_TAG=latest
FROM ${REGISTRY}iossifovlab-http:${BASE_IMAGE_TAG}

COPY ./sites-available/ /etc/apache2/sites-available/
ADD ./supervisord-bootstrap.sh.d/ /supervisord-bootstrap.sh.d/
