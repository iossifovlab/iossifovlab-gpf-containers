#!/bin/bash

set -e

for impala_host in ${IMPALA_HOSTS}; do
    echo "waiting for impala on ${impala_host}..."
    /wait-for-it.sh ${impala_host}:21050 -t 300
    echo "done..."
done

wdaemanage.py migrate

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


if [[ ! -z "${GOOGLE_ANALYTICS_UA}" ]]; then

sed -i "s/\/\/ gtag/gtag('config', '${GOOGLE_ANALYTICS_UA}');/g" /site/gpf/index.html

fi

if [[ ! -z "${GPF_PREFIX}" ]]; then
sed -i "s/gpf_prefix/${GPF_PREFIX}/g" /site/gpf/index.html
sed -i "s/gpf_prefix/${GPF_PREFIX}/g" /etc/apache2/sites-available/localhost.conf

fi


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
