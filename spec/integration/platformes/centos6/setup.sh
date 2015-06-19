#!/bin/sh

set -e
PROJECT_NAME=rundock_spec
PLATFORM_NAME=centos6
DOCKER_DIR="spec/integration/platformes/${PLATFORM_NAME}"
DOCKER_IMAGE_NAME="${PROJECT_NAME}/${PLATFORM_NAME}"
DOCKER_CACHE_IMAGE_PATH="~/.docker/image.tar"
DOCKER_SSH_PORT=22222
DOCKER_SSH_USER=tester
DOCKER_SSH_KEY_PRIVATE="${HOME}/.ssh/id_rsa_${PROJECT_NAME}_${PLATFORM_NAME}_tmp"
DOCKER_SSH_KEY_PUBLIC_LOCAL="${HOME}/.ssh/id_rsa_${PROJECT_NAME}_${PLATFORM_NAME}_tmp.pub"
DOCKER_SSH_KEY_PUBLIC_REMOTE="${DOCKER_DIR}/authorized_keys"
DOCKER_SSH_CONFIG="${HOME}/.ssh/config_${PROJECT_NAME}_${PLATFORM_NAME}"

yes | ssh-keygen -N "" -t rsa -f ${DOCKER_SSH_KEY_PRIVATE}
cp ${DOCKER_SSH_KEY_PUBLIC_LOCAL} ${DOCKER_SSH_KEY_PUBLIC_REMOTE}

if sudo docker ps | grep "${DOCKER_IMAGE_NAME}" > /dev/null 2>&1; then
  sudo docker ps -q | xargs sudo docker rm -f > /dev/null
fi

if file ${DOCKER_CACHE_IMAGE_PATH} | grep empty; then
  sudo docker load --input ${DOCKER_CACHE_IMAGE_PATH}
fi

sudo docker build -t "${DOCKER_IMAGE_NAME}" ${DOCKER_DIR}
rm -f ${DOCKER_SSH_KEY_PUBLIC_REMOTE}
mkdir -p ~/.docker
sudo docker save "${DOCKER_IMAGE_NAME}" > ~/.docker/image.tar
sudo docker run -d --privileged -p ${DOCKER_SSH_PORT}:22 "${DOCKER_IMAGE_NAME}"

echo "Host ${PLATFORM_NAME}"                          >  $DOCKER_SSH_CONFIG
echo "        HostName 127.0.0.1"                     >> $DOCKER_SSH_CONFIG
echo "        User     ${DOCKER_SSH_USER}"            >> $DOCKER_SSH_CONFIG
echo "        Port     ${DOCKER_SSH_PORT}"            >> $DOCKER_SSH_CONFIG
echo "        IdentityFile ${DOCKER_SSH_KEY_PRIVATE}" >> $DOCKER_SSH_CONFIG
echo "        StrictHostKeyChecking no"               >> $DOCKER_SSH_CONFIG
