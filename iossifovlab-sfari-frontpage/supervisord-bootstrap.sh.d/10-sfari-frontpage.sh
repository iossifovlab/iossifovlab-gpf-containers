#!/bin/bash

set -e

echo "$0: replacing placeholder environment object with a production environment object"

dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd "$dir"

# the script expects a frontpage prefix, a gpf oauth instance and at least one gpf instance to be defined as follows

#GPF_FRONTPAGE_INSTANCE_PREFIX=frontpage_prefix
#GPF_OAUTH_ENDPOINT=localhost:9000
#GPF_OAUTH_PREFIX=gpf_prefix
#GPF_INSTANCES_1_ENDPOINT=localhost:9000
#GPF_INSTANCES_1_PREFIX=gpf_prefix
#GPF_INSTANCES_1_API_PATH=/api/v3/
#GPF_INSTANCES_1_FRONTEND_PATH=/
#GPF_INSTANCES_2_ENDPOINT=localhost:9000
#GPF_INSTANCES_2_PREFIX=gpf_prefix2
#GPF_INSTANCES_2_API_PATH=/api/v3/
#GPF_INSTANCES_2_FRONTEND_PATH=/
# ...


declare -p GPF_FRONTPAGE_INSTANCE_PREFIX &> /dev/null || (echo "gpf frontpage prefix: missing prefix"; exit 1)
declare -p GPF_OAUTH_ENDPOINT &> /dev/null || (echo "gpf oauth instance: at least one declared oauth instance is required"; exit 1)
declare -p GPF_OAUTH_PREFIX &> /dev/null  || (echo "gpf oauth instance: missing prefix"; exit 1)
declare -p GPF_INSTANCES_1_ENDPOINT &> /dev/null || (echo "gpf instances: at least one declared instance is required"; exit 1)

#
# placeholder object
#

# the placeholder object is hardcoded, it must be changed if the environment object changes
# the formatting is intentional  - the string must be evalutated as one line without spaces
placeholder_environment_object=''\
'{'\
'production:!0,'\
'oauthClientId:"gpfjs-frontpage",'\
'instances:'\
'{'\
'thisPropertyAndObjectMustBeReplacedWhenInProdution:'\
'{'\
'apiPath:"mustBeReplacedWhenInProduction:http://localhost:9000/gpf_prefix/api/v3/",'\
'frontendPath:"mustBeReplacedWhenInProduction:http://localhost:9000/gpf_prefix/"'\
'}'\
'},'\
'authPath:"mustBeReplacedWhenInProduction:http://localhost:9000/gpf_prefix/"'\
'}'


# check that the placeholder environment object exists in the to be patched .js file
if ! grep -q -F -e "$placeholder_environment_object" /site/frontpage/main.*.js; then
	echo "could not find minified environment object !"
	exit 1
fi

#
# create the production environment object
#

# header

production_environment_object=''\
'{'\
'production:!0,'\
'oauthClientId:"gpfjs-frontpage",'\

# populate the gpf instances object
production_environment_object+=''\
'instances:'\
'{'


# add all declared gpf instances

i=1
while declare -p "GPF_INSTANCES_${i}_ENDPOINT" &> /dev/null; do
	declare -p  "GPF_INSTANCES_${i}_PREFIX" &> /dev/null || (echo "gpf instance [$i]: frontend path is not declared"; exit 1)
	declare -p  "GPF_INSTANCES_${i}_FRONTEND_PATH" &> /dev/null || (echo "gpf instance [$i]: frontend path is not declared"; exit 1)
	declare -p  "GPF_INSTANCES_${i}_API_PATH" &> /dev/null || (echo "gpf instance [$i]: api path is not declared"; exit 1)
	declare -n name="GPF_INSTANCES_${i}_PREFIX"
	declare -n prefix="GPF_INSTANCES_${i}_PREFIX"
	declare -n endpoint="GPF_INSTANCES_${i}_ENDPOINT"
	declare -n frontend_path="GPF_INSTANCES_${i}_FRONTEND_PATH"
	declare -n api_path="GPF_INSTANCES_${i}_API_PATH"

	production_environment_object+=''\
"$name"':'\
'{'\
'apiPath:"'"http://$endpoint/$prefix/$api_path"'",'\
'frontendPath:"'"http://$endpoint/$prefix/$frontend_path"'",'\
'},'

	i=$((i+1))
done;

# strip trailing comma in the property list of the gpf instances object
if [ "$i" -gt 1 ]; then
	production_environment_object="${production_environment_object:0:-1}"
fi

# close the gpf instances object
production_environment_object+=''\
'},'


production_environment_object+=''\
'authPath:"'"http://$GPF_OAUTH_ENDPOINT/$GPF_OAUTH_PREFIX"'"'\
'}'

# done !

#
# replace the placeholder object with the production environment object
#

sed -i -e 's|'"$placeholder_environment_object"'|'"$production_environment_object"'|' /site/frontpage/main.*.js

#
# replace the base href in index.html
#

sed -i -e 's|<base href="">|<base href="/'"$GPF_FRONTPAGE_INSTANCE_PREFIX"'/">|' /site/frontpage/index.html

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
