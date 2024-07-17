#!/bin/bash
set -e

docker login -u $DOCKER_LOGIN -p $DOCKER_PASSWORD $DOCKER_REGISTRY_URL

if [ $DOCKER_SYSTEM_PRUNE = 'true' ] ; then
    docker system prune -af
fi

last_arg='.'
if [ $NO_CACHE = 'true' ] ; then
    last_arg='--no-cache .'
fi

docker build \
	--pull \
    $no_cache_arg \
	--build-arg DOCKER_REGISTRY_URL=library \
    --build-arg BASE_IMAGE=ubuntu \
    --build-arg BASE_TAG=20.04 \
    --build-arg ONESCRIPT_PACKAGES="yard" \
    -t $DOCKER_REGISTRY_URL/oscript-downloader:latest \
	-f oscript/Dockerfile \
    $last_arg

docker build \
    --build-arg ONEC_USERNAME=$ONEC_USERNAME \
    --build-arg ONEC_PASSWORD=$ONEC_PASSWORD \
    --build-arg ONEC_VERSION=$ONEC_VERSION \
    --build-arg DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
    --build-arg BASE_IMAGE=oscript-downloader \
    --build-arg BASE_TAG=latest \
    -t $DOCKER_REGISTRY_URL/onec-server:$ONEC_VERSION \
    -f server/Dockerfile \
    $last_arg

docker build \
    --build-arg ONEC_USERNAME=$ONEC_USERNAME \
    --build-arg ONEC_PASSWORD=$ONEC_PASSWORD \
    --build-arg ONEC_VERSION=$ONEC_VERSION \
    --build-arg EDT_VERSION="$EDT_VERSION" \
    --build-arg DOWNLOADER_REGISTRY_URL=$DOCKER_REGISTRY_URL \
    --build-arg DOWNLOADER_IMAGE=oscript-downloader \
    --build-arg DOWNLOADER_TAG=latest \
    -t $DOCKER_REGISTRY_URL/edt:$edt_escaped \
    -f edt/Dockerfile \
    $last_arg

docker build \
    --build-arg ONES_REGISTRY_URL=$ONES_REGISTRY_URL \
    --build-arg ONES_IMAGE=$ONES_IMAGE \
    --build-arg ONES_TAG="$ONES_TAG" \
    --build-arg EDT_REGISTRY_URL=$EDT_REGISTRY_URL \
    --build-arg EDT_IMAGE=$EDT_IMAGE \
    --build-arg EDT_TAG=$EDT_TAG \
    -t $DOCKER_REGISTRY_URL/server_edt:$ONEC_VERSION-$edt_escaped \
    -f server_edt/Dockerfile \
    .
    # $last_arg

docker push $DOCKER_REGISTRY_URL/onec-server:$ONEC_VERSION