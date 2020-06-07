#!/bin/bash

DAEMON_FILE='idena-node'
NODE_DIR='idena'
SCRIPT_DIR='idena-scripts'
SCRIPT_NAME='idenaupdate.sh'
SCRIPT_PATH="idena-scripts"

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
echo -e "${GREEN}Preparing installation...${NC}"
sudo apt update
sudo apt install -y git jq curl


echo -e "${GREEN}Creating idena service...${NC}"
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

sudo ufw allow 40403
sudo ufw allow 40404
sudo ufw allow 40405

echo -e "${GREEN}Downloading idena node...${NC}" 
bash autoupdate.sh
sudo bash $HOMEFOLDER/$SCRIPT_DIR/idenaupdate.sh

echo -n -e "${YELLOW}Do you want enable node autoupdate script? [Y,n]:${NC}"
read ANSWER
if [ -z $ANSWER ] || [ $ANSWER = 'Y' ] || [ $ANSWER = 'y' ]; then
  if [[ -z $(sudo -u root crontab -l | grep 'idenaupdate.sh') ]]; then
        sudo -u root crontab -l > cron
        echo -e "0 */1 * * * $HOMEFOLDER/$SCRIPT_PATH/$SCRIPT_NAME >/dev/null 2>&1" >> cron
        sudo -u root crontab cron
        rm cron
  fi
fi

echo -n -e "${YELLOW}Do you want enable mining autostart script? [Y,n]:${NC}"
read ANSWER
if [ -z $ANSWER ] || [ $ANSWER = 'Y' ] || [ $ANSWER = 'y' ]; then
   bash automine.sh
fi

cd $HOMEFOLDER
echo -e "${MAG}Idena node control:${NC}"
echo -e "${CYAN}Start idena node: ${BLUE}sudo systemctl start idena.service${NC}"
echo -e "${CYAN}Stop idena node: ${BLUE}sudo systemctl stop idena.service${NC}"
echo -e "${CYAN}Enabe idena service: ${BLUE}sudo systemctl enable idena.service${NC}"
echo -e "${CYAN}Disable idena service: ${BLUE}sudo systemctl disable idena.service${NC}"
echo -e "${CYAN}Status idena node: ${BLUE}sudo systemctl status idena.service${NC}"

echo -e "${CYAN}For idena.service file editing: ${BLUE}sudo nano /etc/systemd/system/idena.service${NC}"
echo -e "${CYAN}After editing idena.service file: ${BLUE}sudo systemctl daemon-reload${NC}"
echo -e "${GREEN}The log is available on command: ${PURPLE}tail -f ~/idena/datadir/logs/output.log${NC}"

echo -e "${RED}ATTENTION! To view the private key of your node, enter:"
echo -e -n "${PURPLE}"
echo 'cat idena/datadir/keystore/nodekey'
echo -e -n "${NC}"

echo -e "${GREEN}To view the API.KEY of your node, enter:"
echo -e -n "${PURPLE}"
echo 'cat idena/datadir/api.key'
echo -e "${NC}"


 
cd $HOMEFOLDER
rm -rf $HOMEFOLDER/idena-sh
