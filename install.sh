#!/bin/bash

DAEMON_FILE='idena-node'
NODE_DIR='idena'

#color
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
PURPLE="\033[0;35m"
RED='\033[0;31m'
GREEN="\033[0;32m"
NC='\033[0m'
MAG='\e[1;35m'

if [[ "$USER" == "root" ]]; then
        HOMEFOLDER="/root"
 else
        HOMEFOLDER="/home/$USER"
fi

CURRENTDIR=$(pwd)
cd $HOMEFOLDER\idena-sh
if [ ! -d $HOMEFOLDER ]; then mkdir $HOMEFOLDER; fi
echo -e "${YELLOW}Preparing installation...${NC}"
sudo apt update
sudo apt install git

echo -e "${CYAN}Creating idena service...${NC}"
echo "[Unit]" > idena.service
echo "Description=idena" >> idena.service
echo "[Service]" >> idena.service
echo -e "User=$USER" >> idena.service
echo -e "WorkingDirectory=$HOMEFOLDER/$NODE_DIR" >> idena.service
echo -e "ExecStart=$HOMEFOLDER/idena-node --profile=lowpower" >> idena.service
echo "Restart=always" >> idena.service
echo "RestartSec=3" >> idena.service
echo "LimitNOFILE=500000" >> idena.service
echo "[Install]" >> idena.service
echo "WantedBy=default.target" >> idena.service

sudo cp idena.service /etc/systemd/system/idena.service
sudo systemctl enable idena.service
rm idena.service

bash autoupdate.sh

sudo ufw allow 40403
sudo ufw allow 40404
