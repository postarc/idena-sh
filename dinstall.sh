#!/bin/bash


CONTAINER_TIMEZONE=Europe/Moscow
IDENAGO="https://github.com/idena-network/idena-go.git"
IDENAPATH="idena-go"
RELEASEPATH="https://github.com/idena-network/idena-go/releases/download"
RELEASENAME="idena-node-linux-"

#color
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
PURPLE="\033[0;35m"
RED='\033[0;31m'
GREEN="\033[0;32m"
NC='\033[0m'
MAG='\e[1;35m'


apt update
apt install -y docker.io git

#echo ${CONTAINER_TIMEZONE} >/etc/timezone && \
#    ln -sf /usr/share/zoneinfo/${CONTAINER_TIMEZONE} /etc/localtime && \
#    dpkg-reconfigure -f noninteractive tzdata && \
#    echo "Container timezone set to: $CONTAINER_TIMEZONE"

echo -n -e "${YELLOW}Input Docker Name:${NC}"
read DOCKER_NAME

if [ -d $IDENAPATH ]; then git fetch; else git clone $IDENAGO; fi
cd $IDENAPATH
LATEST_TAG=$(git tag --sort=-creatordate | head -1)
LATEST_TAG=${LATEST_TAG//v/}
RELEASENAME+=$LATEST_TAG
wget "$RELEASEPATH/v$LATEST_TAG/$RELEASENAME"
chmod +x $RELEASENAME
mkdir -p /opt/idena/bin
mv $RELEASENAME /opt/idena/bin/idena
