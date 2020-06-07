#!/bin/bash

DAEMON_FILE='idena-node'
NODE_DIR='idena'
SCRIPT_DIR='idena-scripts'
SHELL_DIR='idena-sh'

#color
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
PURPLE="\033[0;35m"
RED='\033[0;31m'
GREEN="\033[0;32m"
NC='\033[0m'
MAG='\e[1;35m'

echo -e "${YELLOW}Stop & remove service...${NC}"
sudo systemctl stop idena.serivce
sudo systemctl disable idena.service
sudo rm /etc/systemd/system/idena.service
echo -e "${YELLOW}Remove directory...${NC}"
if [ -d $NODE_DIR ]; then rm -rf $NODE_DIR; fi
if [ -d $SCRIPT_DIR ]; then rm -rf $SCRIPT_DIR; fi
echo -e "${YELLOW}Cleaning crontab...${NC}"
sudo crontab -l > cron
sed '/$SCRIPT_NAME/d' cron > cronn
sudo crontab cronn
rm cron cronn
echo -e "${YELLOW}Cleaning...${NC}"
#rm -rf $SHELL_DIR
echo -e -n "${GREEN}"; echo 'All Done!!!'; echo -e -n "${NC}"
