#!/bin/bash

DAEMON_FILE='idena-node'
NODE_DIR='idena'
SCRIPT_DIR='idena-scripts'
SHELL_DIR='idena-sh'
SCRIPT1_NAME='idenaupdate.sh'
SCRIPT2_NAME='automineon.sh'
SERVICE_NAME='idena'

if [[ "$USER" == "root" ]]; then
        HOMEFOLDER="/root"
 else
        HOMEFOLDER="/home/$USER"
        SERVICE_NAME="$USER"
fi

#color
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
PURPLE="\033[0;35m"
RED='\033[0;31m'
GREEN="\033[0;32m"
NC='\033[0m'
MAG='\e[1;35m'
cd $HOMEFOLDER
echo -e "${RED}A T T E N T I O N ! ! !${NC}"
echo -e "${RED}You want to save nodekey file [y;N]:${NC}"
read ANSWER
if [ $ANSWER ]; then
   if [ $ANSWER = 'Y' ] || [ $ANSWER = 'y' ]; then
       mv $NODE_DIR/datadir/keystore/nodekey $HOMEFOLDER/
   fi
fi
echo -e "${YELLOW}Stop & remove service...${NC}"
sudo systemctl stop $SERVICE_NAME.serivce
sudo systemctl disable $SERVICE_NAME.service
sudo rm /etc/systemd/system/$SERVICE_NAME.service
echo -e "${YELLOW}Remove directory...${NC}"
if [ -d $NODE_DIR ]; then sudo rm -rf $NODE_DIR; fi
if [ -d $SCRIPT_DIR ]; then sudo rm -rf $SCRIPT_DIR; fi
echo -e "${YELLOW}Cleaning crontab...${NC}"
sudo crontab -l > cron
sed /$HOMEFOLDER\\/$SCRIPT_DIR\\/$SCRIPT1_NAME/d cron > cronn
sed /$HOMEFOLDER\\/$SCRIPT_DIR\\/$SCRIPT2_NAME/d cronn > cron
sudo crontab cron
rm cron cronn
echo -e "${YELLOW}Cleaning...${NC}"
rm -rf $SHELL_DIR
echo -e -n "${GREEN}"; echo 'All Done!!!'; echo -e -n "${NC}"
