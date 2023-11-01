#!/bin/bash

a2enmod headers
a2enmod session
a2enmod session_cookie
a2enmod session_crypto

for sitename in ${APACHE2_GPF_SITES}; do
    echo "enabling apache site: ${sitename}..."
    a2ensite $sitename
done

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
