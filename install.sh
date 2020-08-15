#!/bin/bash

DAEMON_FILE='idena-node'
NODE_DIR='idena'
SCRIPT_DIR='idena-scripts'
SCRIPT_NAME='idenaupdate.sh'
SCRIPT_PATH="idena-scripts"
SERVICE_NAME='idena'
RPCPORT=9009
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

if [[ "$USER" == "root" ]]; then
        HOMEFOLDER="/root"
 else
        HOMEFOLDER="/home/$USER"
        SERVICE_NAME="$USER"
fi

while [ -n "$(sudo lsof -i -s TCP:LISTEN -P -n | grep $RPCPORT)" ]
do
(( RPCPORT++))
done

while [ -n "$(sudo lsof -i -s TCP:LISTEN -P -n | grep $IPFSPORT)" ]
do
(( IPFSPORT++))
done


CURRENTDIR=$(pwd)
cd $HOMEFOLDER/idena-sh
if [ ! -d $HOMEFOLDER/$NODE_DIR ]; then mkdir $HOMEFOLDER/$NODE_DIR; fi
echo -e "${GREEN}Preparing installation...${NC}"
sudo apt update
sudo apt install -y git jq curl


echo -e "${GREEN}Creating idena service...${NC}"
echo "[Unit]" > $SERVICE_NAME.service
echo "Description=idena" >> $SERVICE_NAME.service
echo "[Service]" >> $SERVICE_NAME.service
echo -e "User=$USER" >> $SERVICE_NAME.service
echo -e "WorkingDirectory=$HOMEFOLDER/$NODE_DIR" >> $SERVICE_NAME.service
echo -e "ExecStart=$HOMEFOLDER/$NODE_DIR/idena-node --profile=lowpower --rpcport $RPCPORT --ipfsport $IPFSPORT" >> $SERVICE_NAME.service
echo "Restart=always" >> $SERVICE_NAME.service
echo "RestartSec=3" >> $SERVICE_NAME.service
echo "LimitNOFILE=500000" >> $SERVICE_NAME.service
echo "[Install]" >> $SERVICE_NAME.service
echo "WantedBy=default.target" >> $SERVICE_NAME.service

sudo cp $SERVICE_NAME.service /etc/systemd/system/$SERVICE_NAME.service
sudo systemctl enable $SERVICE_NAME.service
rm $SERVICE_NAME.service

sudo ufw allow 40403
sudo ufw allow 40404
sudo ufw allow $IPFSPORT
sudo ufw allow $RPCPORT

echo -e "${GREEN}Downloading idena node...${NC}" 
bash autoupdate.sh
sudo bash $HOMEFOLDER/$SCRIPT_DIR/idenaupdate.sh

echo -n -e "${YELLOW}Do you want enable node autoupdate script? [Y,n]:${NC}"
read ANSWER
if [ -z $ANSWER ] || [ $ANSWER = 'Y' ] || [ $ANSWER = 'y' ]; then
  if [[ -z $(sudo -u root crontab -l | grep "$HOMEFOLDER/$SCRIPT_PATH/$SCRIPT_NAME") ]]; then
        sudo -u root crontab -l > cron
        echo -e "0 */1 * * * $HOMEFOLDER/$SCRIPT_PATH/$SCRIPT_NAME >/dev/null 2>&1" >> cron
        sudo -u root crontab cron
        rm cron
  fi
fi

echo -n -e "${YELLOW}Do you want enable mining autostart script? [y,N]:${NC}"
read ANSWER
if [ $ANSWER]; then
   if [ $ANSWER = 'Y' ] || [ $ANSWER = 'y' ]; then
   bash automine.sh
   fi
fi

cd $HOMEFOLDER
echo -e "${MAG}Idena node control:${NC}"
echo -e "${CYAN}Start idena node: ${BLUE}sudo systemctl start $SERVICE_NAME.service${NC}"
echo -e "${CYAN}Stop idena node: ${BLUE}sudo systemctl stop $SERVICE_NAME.service${NC}"
echo -e "${CYAN}Enabe idena service: ${BLUE}sudo systemctl enable $SERVICE_NAME.service${NC}"
echo -e "${CYAN}Disable idena service: ${BLUE}sudo systemctl disable $SERVICE_NAME.service${NC}"
echo -e "${CYAN}Status idena node: ${BLUE}sudo systemctl status $SERVICE_NAME.service${NC}"

echo -e "${CYAN}For idena.service file editing: ${BLUE}sudo nano /etc/systemd/system/$SERVICE_NAME.service${NC}"
echo -e "${CYAN}After editing idena.service file: ${BLUE}sudo systemctl daemon-reload${NC}"
echo -e "${GREEN}The log is available on command: ${PURPLE}tail -f ~/idena/datadir/logs/output.log${NC}"

echo -e -n "${RED}ATTENTION! Your private key:"
cat idena/datadir/keystore/nodekey
echo
echo -e "To view the private key of your node, enter:"
echo -e -n "${PURPLE}"
echo 'cat idena/datadir/keystore/nodekey'
echo -e -n "${NC}"
echo -e -n "${GREEN}Your API.KEY:"
cat idena/datadir/api.key
echo -e "To view the API.KEY of your node, enter:"
echo -e -n "${PURPLE}"
echo 'cat idena/datadir/api.key'
echo -e "${NC}"
echo -e "${GREEN}Your RPC Port: $RPCPORT. Use it for tunnel settings.${NC}"
echo

 
cd $HOMEFOLDER
rm -rf $HOMEFOLDER/idena-sh
