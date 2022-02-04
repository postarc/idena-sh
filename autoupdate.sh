#!/usr/bin/env bash

SCRIPT_NAME="idenaupdate.sh"
DAEMON_FILE="idena-go"
SCRIPT_PATH="idena-scripts"
DAEMON_PATH="idena"

#if [[ "$USER" == "root" ]]; then
#        HOMEFOLDER="/root"
#        SERVICE_NAME='idena-root'
# else
#        HOMEFOLDER="/home/$USER"
#        SERVICE_NAME="idena-$USER"
#fi
SERVICE_NAME="idena"

CURRENTDIR=$(pwd)
if [ ! -d $HOMEFOLDER/$SCRIPT_PATH ]; then mkdir $HOMEFOLDER/$SCRIPT_PATH; fi
cd $HOMEFOLDER/$SCRIPT_PATH

echo "Create script file..."

echo "#!/bin/bash" > $SCRIPT_NAME
echo >> $SCRIPT_NAME
echo 'FILE_NAME="idena-go"' >> $SCRIPT_NAME
echo >> $SCRIPT_NAME
echo 'wget https://api.github.com/repos/idena-network/idena-go/releases/latest' >> $SCRIPT_NAME
echo 'if [ -f ./latest ]; then' >> $SCRIPT_NAME
echo '   LATEST_TAG=$(jq --raw-output '"'"'.tag_name'"'"' "./latest")' >> $SCRIPT_NAME
echo '   LATEST_TAG=${LATEST_TAG//v/}' >> $SCRIPT_NAME
echo -n '   DAEMON_VERSION=$(' >> $SCRIPT_NAME
echo -n -e "$HOMEFOLDER/$DAEMON_PATH/$DAEMON_FILE -v | awk " >> $SCRIPT_NAME
echo ''\''{print $3}'\'')' >> $SCRIPT_NAME
echo '   if [ -z $DAEMON_VERSION ]; then DAEMON_VERSION="new"; fi' >> $SCRIPT_NAME
echo '   if [ $DAEMON_VERSION != $LATEST_TAG ]; then' >> $SCRIPT_NAME
echo -n '      curl -JL -o ./$FILE_NAME $' >> $SCRIPT_NAME
echo '(jq --raw-output '"'"'.assets | map(select(.name | startswith("idena-node-linux"))) | .[0].browser_download_url'"'"' "./latest")' >> $SCRIPT_NAME
echo '      if [ -f $FILE_NAME ]; then' >> $SCRIPT_NAME
echo '         chmod +x $FILE_NAME' >> $SCRIPT_NAME
echo '         pKILL=$(pwdx $(ps -e | grep idena | awk '"'"'{print $1 }'"'"') | grep /root)' >> $SCRIPT_NAME
echo '         pKILL=$(echo $pKILL | awk '"'"'{print $1}'"'"' | sed 's/.$//')' >> $SCRIPT_NAME
echo -n '         if [ ! -z pKILL ]; then systemctl ' >> $SCRIPT_NAME
echo -e "stop $SERVICE_NAME.service; fi" >> $SCRIPT_NAME
echo -n '         mv $FILE_NAME ' >> $SCRIPT_NAME
echo -e "$HOMEFOLDER/$DAEMON_PATH/$DAEMON_FILE" >> $SCRIPT_NAME
echo -e "         systemctl start $SERVICE_NAME.service" >> $SCRIPT_NAME
echo '      fi' >> $SCRIPT_NAME
echo '   fi' >> $SCRIPT_NAME
echo 'fi' >> $SCRIPT_NAME
echo 'rm latest*' >> $SCRIPT_NAME
chmod +x $SCRIPT_NAME
cd $CURRENTDIR

