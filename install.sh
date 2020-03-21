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
cd $HOMEFOLDER/idena-sh
if [ ! -d $HOMEFOLDER/$NODE_DIR ]; then mkdir $HOMEFOLDER/$NODE_DIR; fi
echo -e "${YELLOW}Preparing installation...${NC}"
sudo apt update
sudo apt install git

echo -e "${YELLOW}Creating idena service...${NC}"
echo "[Unit]" > idena.service
echo "Description=idena" >> idena.service
echo "[Service]" >> idena.service
echo -e "User=$USER" >> idena.service
echo -e "WorkingDirectory=$HOMEFOLDER/$NODE_DIR" >> idena.service
echo -e "ExecStart=$HOMEFOLDER/$NODE_DIR/idena-node --profile=lowpower" >> idena.service
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
sudo ufw allow 40405

echo -e "${GREEN}Starting idena node...${NC}" 
sudo bash $HOMEFOLDER/idena-scripts/autoupdate.sh
echo -e "${MAG}Idena node control:${NC}"
echo -e "${CYAN}Start idena node: ${BLUE}sudo systemctl start idena.service${NC}"
echo -e "${CYAN}Stop idena node: ${BLUE}sudo systemctl stop idena.service${NC}"
echo -e "${CYAN}Enabe idena service: ${BLUE}sudo systemctl enable idena.service${NC}"
echo -e "${CYAN}Disable idena service: ${BLUE}sudo systemctl disable idena.service${NC}"
echo -e "${CYAN}Status idena node: ${BLUE}sudo systemctl status idena.service${NC}"

echo -e "${CYAN}For idena.service file editing: ${BLUE}sudo nano /etc/systemd/system/idena.service${NC}"
echo -e "${CYAN}After editing idena.service file: ${BLUE}sudo systemctl daemon-reload${NC}"
echo -e "${GREEN}The log is available on command: ${PURPLE}tail -f ~/idena/datadir/logs/output.log${NC}"

 
cd $HOMEFOLDER
rm -rf $HOMEFOLDER/idena-sh
