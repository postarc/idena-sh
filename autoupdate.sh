#!/bin/bash

SCRIPT_NAME="idenaupdate.sh"
SCRIPT_PATH="idena-scripts"
DAEMON_PATH="idena"
PATH_NAME="https://github.com/idena-network/idena-go.git"
RPATH_NAME="https://github.com/idena-network/idena-go/releases/download"
if [[ "$USER" == "root" ]]; then
        HOMEFOLDER="/root"
 else
        HOMEFOLDER="/home/$USER"
fi

CURRENTDIR=$(pwd)
if [ ! -d $HOMEFOLDER/$SCRIPT_PATH ]; then mkdir $HOMEFOLDER/$SCRIPT_PATH; fi
cd $HOMEFOLDER/$SCRIPT_PATH

if [[ -z $(sudo -u root crontab -l | grep 'idenaupdate.sh') ]]; then
        sudo -u root crontab -l > cron
        echo -e "0 */1 * * * $HOMEFOLDER/$SCRIPT_PATH/idenaupdate.sh >/dev/null 2>&1" >> cron
        sudo -u root crontab cron
        rm cron
fi
echo "Create script file..."

echo "#!/bin/bash" > $SCRIPT_NAME
echo >> $SCRIPT_NAME
echo -e "GITPATH=$PATH_NAME" >> $SCRIPT_NAME
echo -e "RELEASES_PATH=$RPATH_NAME" >> $SCRIPT_NAME
echo 'FILE_NAME="idena-node-linux-"' >> $SCRIPT_NAME
echo 'CURRENTDIR=$(pwd)' >> $SCRIPT_NAME
echo -e "cd $HOMEFOLDER/$SCRIPT_PATH" >> $SCRIPT_NAME
echo 'if [ -d idena-go ]; then' >> $SCRIPT_NAME
echo '  cd idena-go' >> $SCRIPT_NAME
echo '  git fetch' >> $SCRIPT_NAME
echo '  else' >> $SCRIPT_NAME
echo '  git clone $GITPATH' >> $SCRIPT_NAME
echo '  cd idena-go' >> $SCRIPT_NAME
echo 'fi' >> $SCRIPT_NAME

#echo -e "chown -R $USER:$USER $HOMEFOLDER/idena-go" >> $SCRIPT_NAME
echo 'LATEST_TAG=$(git tag --sort=-creatordate | head -1)' >> $SCRIPT_NAME
echo 'cd ..' >> $SCRIPT_NAME
echo 'LATEST_TAG=${LATEST_TAG//v/}' >> $SCRIPT_NAME
echo -n 'if [[ -z $' >> $SCRIPT_NAME
echo -n -e "($HOMEFOLDER/$DAEMON_PATH/idena-node -v | grep " >> $SCRIPT_NAME
echo '$LATEST_TAG) ]]; then' >> $SCRIPT_NAME
echo '  FILE_NAME+=$LATEST_TAG' >> $SCRIPT_NAME
echo '  if [ -f $FILE_NAME ]; then rm $FILE_NAME; fi' >> $SCRIPT_NAME
echo '  wget "$RELEASES_PATH/v$LATEST_TAG/$FILE_NAME"' >> $SCRIPT_NAME
echo '  chmod +x $FILE_NAME' >> $SCRIPT_NAME
echo '  mv $FILE_NAME $HOMEFOLDER/$DAEMON_PATH/idena-node' >> $SCRIPT_NAME
echo 'fi' >> $SCRIPT_NAME

#echo 'LATEST_TAG=$( ps -e | grep idena-node | awk '{print $1}' )' >> $SCRIPT_NAME
#echo 'if [ -z $LATEST_TAG ]; then systemctl start nkn.service; fi' >> $SCRIPT_NAME
#echo 'cd $CURRENTDIR' >> $SCRIPT_NAME

chmod +x $SCRIPT_NAME
cd $CURRENTDIR

