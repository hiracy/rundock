#!/bin/sh

set -e

PROJECT_NAME=rundock_spec
PLATFORM_NAME=centos6
DOCKER_DIR="spec/integration/platformes/${PLATFORM_NAME}"
DOCKER_IMAGE_NAME="${PROJECT_NAME}/${PLATFORM_NAME}"
DOCKER_SSH_PORT=22222
DOCKER_SSH_USER=tester
DOCKER_SSH_KEY_PRIVATE="~/.ssh/id_rsa_tmp"
DOCKER_SSH_KEY_PUBLIC_LOCAL="~/.ssh/id_rsa_tmp.pub"
DOCKER_SSH_KEY_PUBLIC_REMOTE="${DOCKER_DIR}/authorized_keys"
DOCKER_SSH_CONFIG="~/.ssh/config_${PROJECT_NAME}_${PLATFORM_NAME}"

yes | ssh-keygen -N "" -t rsa -f ${DOCKER_SSH_KEY_PRIVATE}
cp ${DOCKER_SSH_KEY_PUBLIC_LOCAL} ${DOCKER_SSH_KEY_PUBLIC_REMOTE}

if sudo docker ps | grep "${DOCKER_IMAGE_NAME}" > /dev/null 2>&1; then
  sudo docker ps -q | xargs sudo docker rm -f > /dev/null
fi

if [[ -e ~/.docker/image.tar ]]; then
  sudo docker load --input ~/.docker/image.tar
fi

sudo docker build -t "${DOCKER_IMAGE_NAME}" ${DOCKER_DIR}
rm -f ${DOCKER_SSH_KEY_PUBLIC_REMOTE}
mkdir -p ~/.docker
sudo docker save "${DOCKER_IMAGE_NAME}" > ~/.docker/image.tar
sudo docker run -d --privileged -p ${DOCKER_SSH_PORT}:22 "${DOCKER_IMAGE_NAME}"

echo "Host ${PLATFORM_NAME}"                          >  $SSH_CONFIG
echo "        HostName 127.0.0.1"                     >> $SSH_CONFIG
echo "        User     ${DOCKER_SSH_USER}"            >> $SSH_CONFIG
echo "        Port     ${DOCKER_SSH_PORT}"            >> $SSH_CONFIG
echo "        IdentityFile ${DOCKER_SSH_KEY_PRIVATE}" >> $SSH_CONFIG
echo "        StrictHostKeyChecking no"               >> $SSH_CONFIG
