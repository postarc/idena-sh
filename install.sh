#!/usr/bin/env bash

DAEMON_FILE='idena-go'
RELEASES_PATH="https://github.com/idena-network/idena-go/releases/download"
FILE_NAME="idena-node-linux-"
NODE_DIR='idena'
SCRIPT_DIR='idena-scripts'
SCRIPT_NAME='idenaupdate.sh'
SCRIPT_PATH="idena-scripts"
RPCPORT=9009
#PORT=50499
P2P_PORT=40404
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
        SERVICE_NAME='idena-root'
 else
        HOMEFOLDER="/home/$USER"
        SERVICE_NAME="idena-$USER"
fi

#while [ -n "$(sudo lsof -i -s TCP:LISTEN -P -n | grep $RPCPORT)" ]
#do
#(( RPCPORT--))
#done

#while [ -n "$(sudo lsof -i -s TCP:LISTEN -P -n | grep $IPFSPORT)" ]
#do
#(( IPFSPORT++))
#done

#while [ -n "$(sudo lsof -i -s TCP:LISTEN -P -n | grep $P2P_PORT)" ]
#do
#(( P2P_PORT++))
#done

#while [ -n "$(sudo lsof -i -s TCP:LISTEN -P -n | grep $PORT)" ]
#do
#(( IPFSPORT--))
#done

CURRENTDIR=$(pwd)
cd $HOMEFOLDER/idena-sh
if [ ! -d $HOMEFOLDER/$NODE_DIR ]; then mkdir $HOMEFOLDER/$NODE_DIR; fi
echo -e "${GREEN}Preparing installation...${NC}"
apt --help > /dev/null
if type apt-get; then
      sudo apt update
      sudo apt install -y jq curl unzip wget
elif type yum; then
      sudo yum check-update
      sudo yum install epel-release -y
      sudo yum update -y
      sudo yum install -y jq curl unzip wget
fi

echo -e "{\n  \"P2P\": {\n   \"ListenAddr\": \": $P2P_PORT\"," > $HOMEFOLDER/$NODE_DIR/config.json
echo -e "   \"MaxInboundPeers\": 12," >> $HOMEFOLDER/$NODE_DIR/config.json
echo -e "   \"MaxOutboundPeers\": 6  },\n" >> $HOMEFOLDER/$NODE_DIR/config.json
echo -e "  \"RPC\": {\n   \"HTTPHost\": \"localhost\",\n   \"HTTPPort\": $RPCPORT },\n" >> $HOMEFOLDER/$NODE_DIR/config.json
echo -e "  \"Ipfsconf\": {\n   \"Profile\": \"server\",\n   \"IpfsPort\": $IPFSPORT },\n" >> $HOMEFOLDER/$NODE_DIR/config.json
echo -e "  \"Sync\": {\n   \"FastSync\": true }\n }" >> $HOMEFOLDER/$NODE_DIR/config.json

echo -n -e "${YELLOW}Do you want reduce bandwidth usage and connected peer count down to 9? [Y,n]:${NC}"
read ANSWER
if [ -z $ANSWER ] || [ $ANSWER = 'Y' ] || [ $ANSWER = 'y' ]; then
   BANDWITH="--profile=lowpower"
else BANDWITH=""
fi
#BANDWITH=""

echo -n -e "${YELLOW}Do you want to change a service priority (niceness min=-20 max=20) [Default=0]:${NC}"
read PNICE
if [ -n "$PNICE" ] && [ "$PNICE" -eq "$PNICE" ] 2>/dev/null; then
   if [ $PNICE -lt -20 ] || [ $PNICE -gt 20 ]; then SNICE="";
   else 
        if [ $PNICE -ne 0 ]; then SNICE="/usr/bin/nice -n $PNICE ";
        else SNICE=""; fi
   fi
else SNICE=""; fi

echo -e "${GREEN}Creating idena service...${NC}"
if [ -e /etc/systemd/system/idena.service ]; then 
   sudo systemctl stop idena.service
   sudo systemctl disable idena.service
   sudo rm /etc/systemd/system/idena.service
fi
echo "[Unit]" > $SERVICE_NAME.service
echo "Description=$SERVICE_NAME" >> $SERVICE_NAME.service
echo "[Service]" >> $SERVICE_NAME.service
echo -e "User=$USER" >> $SERVICE_NAME.service
echo -e "WorkingDirectory=$HOMEFOLDER/$NODE_DIR" >> $SERVICE_NAME.service
echo -e "ExecStart=$SNICE$HOMEFOLDER/$NODE_DIR/$DAEMON_FILE --config $HOMEFOLDER/$NODE_DIR/config.json $BANDWITH">> $SERVICE_NAME.service 
echo "Restart=always" >> $SERVICE_NAME.service
echo "RestartSec=3" >> $SERVICE_NAME.service
echo "LimitNOFILE=500000" >> $SERVICE_NAME.service
echo "[Install]" >> $SERVICE_NAME.service
echo "WantedBy=default.target" >> $SERVICE_NAME.service

sudo cp $SERVICE_NAME.service /etc/systemd/system/$SERVICE_NAME.service
sudo systemctl enable $SERVICE_NAME.service
rm $SERVICE_NAME.service
sudo systemctl daemon-reload
sudo systemctl stop $SERVICE_NAME.service

if type apt-get; then
   sudo ufw allow $IPFSPORT
   sudo ufw allow $RPCPORT
   sudo ufw allow $P2P_PORT
fi

echo -e "${GREEN}Downloading idena node...${NC}" 
if [ -d $HOMEFOLDER/$NODE_DIR/datadir/ipfs ]; then rm -rf $HOMEFOLDER/$NODE_DIR/datadir/ipfs; fi
bash autoupdate.sh
sudo bash $HOMEFOLDER/$SCRIPT_DIR/$SCRIPT_NAME

if [ ! -f $HOMEFOLDER/$NODE_DIR/$DAEMON_FILE ]; then
        echo -e "${RED}Latest release not found, downloading previous ...${NC}"
        cd $HOMEFOLDER/$SCRIPT_DIR/$DAEMON_FILE
        LATEST_TAG=$(git tag --sort=-creatordate | head -2 | sed '1d')
        LATEST_TAG=${LATEST_TAG//v/}
        FILE_NAME+=$LATEST_TAG
        sudo wget  "$RELEASES_PATH/v$LATEST_TAG/$FILE_NAME"
        sudo chmod +x $FILE_NAME
        sudo mv $FILE_NAME $HOMEFOLDER/$NODE_DIR/$DAEMON_FILE
        cd $HOMEFOLDER
fi

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
echo -n -e "${YELLOW}Do you want download idenachain.db.zip for fast sync? [Y,n]:${NC}"
read ANSWER
if [ -z $ANSWER ] || [ $ANSWER = 'Y' ] || [ $ANSWER = 'y' ]; then
        wget https://sync.idena-ar.com/idenachain.db.zip
        if [ ! -d $HOMEFOLDER/$NODE_DIR/datadir/idenachain.db ]; then mkdir $HOMEFOLDER/$NODE_DIR/datadir/idenachain.db;
        else rm -rf $HOMEFOLDER/$NODE_DIR/datadir/idenachain.db/*; fi
        unzip -o idenachain.db.zip -d $HOMEFOLDER/$NODE_DIR/datadir/idenachain.db/
        rm idenachain.db.zip
fi        
#echo -n -e "${YELLOW}Do you want enable mining autostart script? [y,N]:${NC}"
#read ANSWER
#if [ $ANSWER ]; then
#   if [ $ANSWER = 'Y' ] || [ $ANSWER = 'y' ]; then
#   bash automine.sh
#   fi
#fi
echo -e "${GREEN}Starting idena node...${NC}" 
sudo systemctl start $SERVICE_NAME.service
sleep 10
echo
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

echo -e -n "${RED}ATTENTION! Your private key: "
cat idena/datadir/keystore/nodekey
echo
echo -e -n "To view the private key of your node, enter: "
echo -e -n "${PURPLE}"
echo 'cat idena/datadir/keystore/nodekey'
echo -e -n "${NC}"
echo -e -n "${GREEN}Your API.KEY: "
cat idena/datadir/api.key
echo
echo -e "To view the API.KEY of your node, enter:"
echo -e -n "${PURPLE}"
echo 'cat idena/datadir/api.key'
echo -e "${NC}"
echo -e "${GREEN}Your RPC Port: $RPCPORT. Use it for tunnel settings.${NC}"
echo

 
cd $HOMEFOLDER
rm -rf $HOMEFOLDER/idena-sh
