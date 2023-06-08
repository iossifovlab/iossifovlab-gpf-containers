#!/bin/bash

set -e

dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd "$dir"

# the script expects a GPF_FRONTPAGE_INSTANCE and at least one gpf instance to be defined as follows

#GPF_FRONTPAGE_INSTANCE_ENDPOINT=localhost:9000
#GPF_FRONTPAGE_INSTANCE_PREFIX=frontpage_prefix
#GPF_INSTANCES_1_ENDPOINT=localhost:9000
#GPF_INSTANCES_1_PREFIX=gpf_prefix
#GPF_INSTANCES_2_ENDPOINT=localhost:9000
#GPF_INSTANCES_2_PREFIX=gpf_prefix2
# ...



# add all declared gpf instances

GPF_INSTANCES_REVERSE_PROXIES_CONFIG=''

i=1
while declare -p "GPF_INSTANCES_${i}_ENDPOINT" &> /dev/null; do
	declare -p  "GPF_INSTANCES_${i}_PREFIX" &> /dev/null || echo "gpf instance [$i]: prefix is not declared"
	declare -n endpoint="GPF_INSTANCES_${i}_ENDPOINT"
	declare -n prefix="GPF_INSTANCES_${i}_PREFIX"

	GPF_INSTANCES_REVERSE_PROXIES_CONFIG+='
	<Location "/${GPF_INSTANCES_'"${i}"'_PREFIX}">
		ProxyPass "http://${GPF_INSTANCES_'"${i}"'_ENDPOINT}/${GPF_INSTANCES_'"${i}"'_PREFIX}"
		ProxyPassReverse "http://${GPF_INSTANCES_'"${i}"'_ENDPOINT}/${GPF_INSTANCES_'"${i}"'_PREFIX}"
		ProxyPreserveHost On
		Allow from all
	</Location>
'

	i=$((i+1))
done;

cat <<<"$GPF_INSTANCES_REVERSE_PROXIES_CONFIG" > /etc/apache2/sites-available/localhost.conf.gpf_instances_reverse_proxies

a2enmod headers
a2enmod session
a2enmod session_cookie
a2enmod session_crypto
a2ensite localhost

supervisorctl start apache2

if ! /wait-for-it.sh localhost:80 -t 240; then
    echo -e "\n---------------------------------------"
    echo -e "  Apache2 not ready! Exiting..."
    echo -e "---------------------------------------"
    exit 1
fi

echo -e "\n\n--------------------------------------------------------------------------------"
echo -e "Apache2 running..."
echo -e "--------------------------------------------------------------------------------\n\n"
