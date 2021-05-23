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


# polling으로 작업이 끝날 떄 까지 기다리다가, 모든 작업이 성공적으로 끝나면, message queue에 enqueue 하기 