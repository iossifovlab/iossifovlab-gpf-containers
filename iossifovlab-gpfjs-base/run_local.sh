#!/bin/bash

set -e


export HAS_NETWORK=`docker network ls | grep gpf-local-network | sed -e "s/\s\{2,\}/\t/g" | cut -f 1`
if [[ -z $HAS_NETWORK ]]; then
    docker network create gpf-local-network
fi


export HAS_GPF_MYSQL=`docker ps -a | grep gpf-local-mysql | sed -e "s/\s\{2,\}/\t/g" | cut -f 1`


if [[ -z $HAS_GPF_MYSQL ]]; then

    docker pull mysql:5.7

    docker create \
        --name gpf-local-mysql \
        --network gpf-local-network \
        --hostname gpf-local-mysql \
        -e "MYSQL_DATABASE=gpf" \
        -e "MYSQL_USER=seqpipe" \
        -e "MYSQL_PASSWORD=secret" \
        -e "MYSQL_ROOT_PASSWORD=secret" \
        -e "MYSQL_PORT=3306" \
        mysql:5.7 \
        --character-set-server=utf8 --collation-server=utf8_bin

fi

export HAS_RUNNING_GPF_MYSQL=`docker ps | grep gpf-local-mysql | sed -e "s/\s\{2,\}/\t/g" | cut -f 1`
echo "Has running GPF MySQL: <${HAS_RUNNING_GPF_MYSQL}>"
if [[ -z $HAS_RUNNING_GPF_MYSQL ]]; then
    echo "starting gpf-local-mysql container..."
    docker start gpf-local-mysql
fi

echo "waiting gpf-local-mysql container..."
sleep 5

echo ""
echo "==============================================="
echo "Local GPF MySQL is READY..."
echo "==============================================="
echo ""



docker run --rm -d \
    --name gpf-local \
    --network gpf-local-network \
    --hostname gpf-local \
    -p 8080:80 \
    -v $DAE_DB_DIR:/data \
    -e DAE_DB_DIR=/data \
    -e WDAE_DB_NAME="gpf" \
    -e WDAE_DB_USER="seqpipe" \
    -e WDAE_DB_PASSWORD="secret" \
    -e WDAE_DB_HOST="gpf-local-mysql" \
    -e WDAE_DB_PORT="3306" \
    -e WDAE_SECRET_KEY="123456789012345678901234567890123456789012345678901234567890" \
    -e WDAE_ALLOWED_HOST="*" \
    -e WDAE_DEBUG="True" \
    -e WDAE_PUBLIC_HOSTNAME="locahost" \
    -e GPF_PREFIX="gpf" \
    -e WDAE_PREFIX="gpf" \
    -e IMPALA_HOSTS="seqclust0.seqpipe.org" \
    seqpipe/seqpipe-gpf-full:latest



