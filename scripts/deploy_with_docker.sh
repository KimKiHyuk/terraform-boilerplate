#! /bin/bash

if [ -x "$(command -v docker)" ]; then
    echo "docker already installed"
else
    echo "download docker install file"
    curl -fsSL https://get.docker.com -o get-docker.sh
    echo "install docker"
    sh get-docker.sh
fi

echo "run specific docker image"
docker run --name app -p $2:$3 -d $1


if [ -f "get-docker.sh" ]; then
    echo "remove file"
    rm get-docker.sh
fi