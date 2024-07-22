#!/bin/bash

set -e

for impala_host in ${IMPALA_HOSTS}; do
    echo "waiting for impala on ${impala_host}..."
    /wait-for-it.sh ${impala_host}:21050 -t 300
    echo "done..."
done

echo "waiting for mysql on '${WDAE_DB_HOST}:${WDAE_DB_PORT}'..."
/wait-for-it.sh ${WDAE_DB_HOST}:${WDAE_DB_PORT} -t 300
echo "done..."


source /gpf/bin/activate

wdaemanage.py migrate

wdaemanage.py collectstatic --noinput

supervisorctl start gpf

/wait-for-it.sh localhost:9001 -t 240

rc=$?
if [ $rc -ne 0 ]; then
    echo -e "\n---------------------------------------"
    echo -e "  gpf gunicorn not ready! Exiting..."
    echo -e "---------------------------------------"
    exit 1
fi

echo -e "\n\n------------------------------------------------------------------------"
echo -e "gpf gunicorn running..."
echo -e "------------------------------------------------------------------------\n\n"


if [[ ! -z "${GPF_PREFIX}" ]]; then
sed -i "s/gpf_prefix/${GPF_PREFIX}/g" /site/gpf/index.html
sed -i "s/gpf_prefix/${GPF_PREFIX}/g" /etc/apache2/sites-available/localhost.conf
fi

if [[ ! -z "${DAE_PHENODB_DIR}" ]]; then
sed -i "s;/data-phenodb/pheno;$DAE_PHENODB_DIR;g" /etc/apache2/sites-available/localhost.conf
fi

if [ "${DOCKER_COMPOSE_CORS_WORKAROUND}" == "True" ]; then
sed -i '/^<VirtualHost \*:80>$/ a\ \ \ \ Header always set Access-Control-Allow-Origin http://localhost:8080\n    Header always set Access-Control-Allow-Credentials true\n    Header always set Access-Control-Allow-Headers "content-type, authorization"' /etc/apache2/sites-available/localhost.conf
fi

if [[ ! -z "${APACHE2_VHOST_LISTEN_PORT}" ]]; then
sed -i "s/<VirtualHost \*:80>/<VirtualHost \*:${APACHE2_VHOST_LISTEN_PORT}>/g" /etc/apache2/sites-available/localhost.conf
sed -i "s/Listen 80/Listen ${APACHE2_VHOST_LISTEN_PORT}/g" /etc/apache2/ports.conf
fi

sed -i "s/Timeout 300/Timeout 1200/g" /etc/apache2/apache2.conf

a2enmod headers

echo "enabling apache site: localhost..."
a2ensite localhost

supervisorctl start apache2

/wait-for-it.sh localhost:80 -t 240

rc=$?
if [ $rc -ne 0 ]; then
    echo -e "\n---------------------------------------"
    echo -e "  Apache2 not ready! Exiting..."
    echo -e "---------------------------------------"
    exit 1
fi

echo -e "\n\n--------------------------------------------------------------------------------"
echo -e "Apache2 running..."
echo -e "--------------------------------------------------------------------------------\n\n"
