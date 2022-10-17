#!/bin/bash

set -e

dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd "$dir"

for i in $(ls -1 supervisord-bootstrap.sh.d/*.sh | sort); do
	# execute only not disabled files
	if ! [ -e "./$i.disabled" ]; then
		"./$i"
	fi
done
