#!/bin/bash


CONTAINER_TIMEZONE=Europe/Moscow
IDENAGO="https://github.com/idena-network/idena-go.git"
IDENAPATH="idena-go"
RELEASEPATH="https://github.com/idena-network/idena-go/releases/download"
RELEASENAME="idena-node-linux-"
RPCPORT=9009
#PORT=50499
P2PPORT=40404
IPFSPORT=40405

#color
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
PURPLE="\033[0;35m"
RED='\033[0;31m'
GREEN="\033[0;32m"
NC='\033[0m'
MAG='\e[1;35m'

#while [ -n "$(sudo lsof -i -s TCP:LISTEN -P -n | grep $RPCPORT)" ]
#do
#(( RPCPORT--))
#done

#while [ -n "$(sudo lsof -i -s TCP:LISTEN -P -n | grep $IPFSPORT)" ]
#do
#(( IPFSPORT++))
#done

#while [ -n "$(sudo lsof -i -s TCP:LISTEN -P -n | grep $P2PPORT)" ]
#do
#(( P2PPORT++))
#done

apt update
apt install -y docker.io git

#echo ${CONTAINER_TIMEZONE} >/etc/timezone && \
#    ln -sf /usr/share/zoneinfo/${CONTAINER_TIMEZONE} /etc/localtime && \
#    dpkg-reconfigure -f noninteractive tzdata && \
#    echo "Container timezone set to: $CONTAINER_TIMEZONE"
mkdir -p /opt/idena/bin

echo -n -e "${YELLOW}Input Docker Name:${NC}"
read DOCKER_NAME
echo -n -e "${YELLOW}Input RPC port number [default: $RPCPORT]:${NC}"
read ANSWER
if [[ ! ${ANSWER} =~ ^[0-9]+$ ]] ; then ANSWER=9009 ; fi
RPCPORT=$ANSWER
echo -n -e "${YELLOW}Input P2P port number [default: $P2PPORT]:${NC}"
read ANSWER
if [[ ! ${ANSWER} =~ ^[0-9]+$ ]] ; then ANSWER=40404 ; fi
P2PPORT=$ANSWER
echo -n -e "${YELLOW}Input IPFS port number [default: $IPFSPORT]:${NC}"
read ANSWER
if [[ ! ${ANSWER} =~ ^[0-9]+$ ]] ; then ANSWER=40405 ; fi
IPFSPORT=$ANSWER


echo $DOCKER_NAME >> /opt/idena/bin/docker-name
echo $RPCPORT >> rpc-port
echo $P2PPORT >> p2p-port
echo $IPFSPORT >> ipfs-port


if [ -d $IDENAPATH ]; then git fetch; else git clone $IDENAGO; fi
cd $IDENAPATH
LATEST_TAG=$(git tag --sort=-creatordate | head -1)
LATEST_TAG=${LATEST_TAG//v/}
RELEASENAME+=$LATEST_TAG
wget "$RELEASEPATH/v$LATEST_TAG/$RELEASENAME"
chmod +x $RELEASENAME
mv $RELEASENAME /opt/idena/bin/idena

