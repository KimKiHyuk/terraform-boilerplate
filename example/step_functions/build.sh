#!/usr/bin/sh
set -xv

while getopts r:f:c: flag
do
    case "${flag}" in
        r) repository_uri=${OPTARG};;
        f) folder=${OPTARG};;
        c) context=${OPTARG};;
    esac
done


echo $repository_uri
echo $folder
echo $context

DATE=$(date -u +%Y-%m-%d:%H-%M-%S)


DOCKER_BUILDKIT=0 docker build --build-arg BUILD_DATE=$DATE -t $repository_uri -f $folder $context
docker push $repository_uri