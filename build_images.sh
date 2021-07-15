#!/bin/bash

set -e

if [ -z $WORKSPACE ];
then
    export WORKSPACE=`pwd`
fi

echo "BUILD_NUMBER: ${BUILD_NUMBER}"


if [ "$1" ]; then
    export PUBLISH=$1
    echo "PUBLISH=${PUBLISH}"
else
    echo 'ERROR: requires a non-empty version PUBLISH argument'
    exit 1
fi


if [ "$2" ]; then
    export GPF_BUILD=$2
    echo "GPF_BUILD=${GPF_BUILD}"
else
    echo 'ERROR: requires a non-empty GPF_BUILD argument'
    exit 1
fi

if [ "$3" ]; then
    export GPF_BRANCH=$3
    echo "GPF_BRANCH=${GPF_BRANCH}"
else
    echo 'GPF_BRANCH argument is empty; assuming release-3.4 branch'
    export GPF_BRANCH="release-3.5"
fi


if [ $GPF_BUILD == "-1" ];
then
    export GPF_BUILD=0
fi

if [ -z ${BUILD_NUMBER} ];
then
    export GPF_BUILD="${GPF_BUILD}_0"
else
    export GPF_BUILD="${GPF_BUILD}_${BUILD_NUMBER}"
fi



if [ ${PUBLISH} == "false" ];
then
    echo "Using local docker registry: registry.seqpipe.org"
    export REGISTRY="registry.seqpipe.org"
else
    if [ ${PUBLISH} == "true" ];
    then
        echo "Using dockerhub registry: seqpipe"
        export REGISTRY="seqpipe"
    else
        exit 1
    fi
fi


# prepare sources
${WORKSPACE}/prepare_sources.sh ${GPF_BRANCH}

cd ${WORKSPACE}

export GPF_VERSION=$(cat seqpipe-gpf/gpf/VERSION)
export GPF_SERIES=$(cut -d "." -f 1-2 seqpipe-gpf/gpf/VERSION)


echo "GPF_VERSION : ${GPF_VERSION}"
echo "GPF_SERIES  : ${GPF_SERIES}"
echo "GPF_BUILD   : ${GPF_BUILD}"

export TAG="${GPF_VERSION}.${GPF_BUILD}"

echo "TAG         : $TAG"
echo "GPF_BRANCH  : $GPF_BRANCH"



docker build seqpipe-builder/ -t "${REGISTRY}/seqpipe-builder:${TAG}"
docker build seqpipe-builder/ -t "${REGISTRY}/seqpipe-builder:latest"


cd seqpipe-http
./build_http.sh ${TAG} ${GPF_BRANCH} ${REGISTRY}
cd ${WORKSPACE}

cd seqpipe-gpf
./build_gpf.sh ${TAG} ${GPF_BRANCH} ${REGISTRY}
cd ${WORKSPACE}


rm -f seqpipe-gpfjs/gpfjs-dist-*.tar.gz
rm -f seqpipe-gpf-full/gpfjs-dist-*.tar.gz

cd seqpipe-gpfjs
./build_gpfjs.sh ${TAG} ${GPF_BRANCH} ${REGISTRY}
cd ${WORKSPACE}

cp seqpipe-gpfjs/gpfjs-dist-default-${TAG}.tar.gz seqpipe-gpf-full

cd seqpipe-gpf-full
./build_gpf_full.sh ${TAG} ${GPF_BRANCH} ${REGISTRY}
cd ${WORKSPACE}

for repo in seqpipe-builder seqpipe-gpfjs seqpipe-gpf seqpipe-gpf-full seqpipe-http; do
    echo "pushing docker image: ${repo}:${TAG}"
    docker push ${REGISTRY}/${repo}:${TAG}
    docker push ${REGISTRY}/${repo}:latest
done


# cd seqpipe-gpfjs/gpfjs
# git tag -f ${TAG}
# git push origin --tags
# cd -

# cd seqpipe-gpf/gpf
# git tag -f ${TAG}
# git push origin --tags
# cd -

# git tag -f ${TAG}
# echo $GPF_BUILD > GPF_BUILD.txt

# git add GPF_BUILD.txt
# git commit -m "new build done"
# git push origin --tags
