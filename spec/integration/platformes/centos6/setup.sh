#!/bin/sh

set -e
PROJECT_ROOT="spec/integration"
PROJECT_NAME=rundock_spec
PLATFORM_NAME=centos6
PLATFORM_DIR="${PROJECT_ROOT}/platformes/${PLATFORM_NAME}"
DOCKER_IMAGE_NAME="${PROJECT_NAME}/${PLATFORM_NAME}"
DOCKER_CACHE_DIR="${HOME}/.docker"
DOCKER_CACHE_IMAGE_PATH="${DOCKER_CACHE_DIR}/image.tar"
DOCKER_SSH_PORT=22222
DOCKER_SSH_USER=tester
DOCKER_SSH_KEY_PRIVATE="${HOME}/.ssh/id_rsa_${PROJECT_NAME}_${PLATFORM_NAME}_tmp"
DOCKER_SSH_KEY_PUBLIC_LOCAL="${HOME}/.ssh/id_rsa_${PROJECT_NAME}_${PLATFORM_NAME}_tmp.pub"
DOCKER_SSH_KEY_PUBLIC_REMOTE="${PLATFORM_DIR}/authorized_keys"
DOCKER_SSH_CONFIG="${HOME}/.ssh/config_${PROJECT_NAME}_${PLATFORM_NAME}"
RUNDOCK_SCENARIO_DIR="${PROJECT_ROOT}/scenarios"
RUNDOCK_CACHE_DIR="${HOME}/.rundock/${PLATFORM_NAME}"
RUNDOCK_DEFAULT_SSH_YML="${RUNDOCK_CACHE_DIR}/integration_default_ssh.yml"
RUNDOCK_SCENARIO_CACHE_DIR="${RUNDOCK_CACHE_DIR}/scenarios"

if [ "${1}x" == "--cleanx" ];then
  sudo docker ps -q | xargs sudo docker rm -f > /dev/null
  sudo rm -fr ~/.rundock
fi

mkdir -p "${RUNDOCK_SCENARIO_CACHE_DIR}"

if [ ! -f ${RUNDOCK_DEFAULT_SSH_YML} ]; then
(
cat << EOP
:port: ${DOCKER_SSH_PORT}
:paranoid: false
:user: "${DOCKER_SSH_USER}"
:keys: ["${DOCKER_SSH_KEY_PRIVATE}"]
EOP
) > ${RUNDOCK_DEFAULT_SSH_YML}
fi

cp ${RUNDOCK_SCENARIO_DIR}/* ${RUNDOCK_SCENARIO_CACHE_DIR}

find ${RUNDOCK_SCENARIO_CACHE_DIR} -type f -name "*_scenario.yml" | \
  xargs sed -i -e "s#<replaced_by_platforms>#${DOCKER_SSH_KEY_PRIVATE}#g"

sudo docker ps | grep "${DOCKER_IMAGE_NAME}" && { echo "docker image is already standing."; exit 0; }

yes | ssh-keygen -N "" -t rsa -f ${DOCKER_SSH_KEY_PRIVATE}
cp ${DOCKER_SSH_KEY_PUBLIC_LOCAL} ${DOCKER_SSH_KEY_PUBLIC_REMOTE}

if sudo docker ps | grep "${DOCKER_IMAGE_NAME}" > /dev/null 2>&1; then
  sudo docker ps -q | xargs sudo docker rm -f > /dev/null
fi

if file ${DOCKER_CACHE_IMAGE_PATH} | grep empty; then
  sudo docker load --input ${DOCKER_CACHE_IMAGE_PATH}
fi

sudo docker build -t "${DOCKER_IMAGE_NAME}" ${PLATFORM_DIR}
rm -f ${DOCKER_SSH_KEY_PUBLIC_REMOTE}
mkdir -p ${DOCKER_CACHE_DIR}
sudo docker save "${DOCKER_IMAGE_NAME}" > ~/.docker/image.tar
sudo docker run -d --privileged -p ${DOCKER_SSH_PORT}:22 "${DOCKER_IMAGE_NAME}"

echo "Host ${PLATFORM_NAME}"                          >  $DOCKER_SSH_CONFIG
echo "        HostName 127.0.0.1"                     >> $DOCKER_SSH_CONFIG
echo "        User     ${DOCKER_SSH_USER}"            >> $DOCKER_SSH_CONFIG
echo "        Port     ${DOCKER_SSH_PORT}"            >> $DOCKER_SSH_CONFIG
echo "        IdentityFile ${DOCKER_SSH_KEY_PRIVATE}" >> $DOCKER_SSH_CONFIG
echo "        StrictHostKeyChecking no"               >> $DOCKER_SSH_CONFIG
