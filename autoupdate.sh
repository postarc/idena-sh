#!/bin/bash

SCRIPT_NAME="idenaupdate.sh"
PATH_NAME="https://github.com/idena-network/idena-go.git"
RPATH_NAME="https://github.com/idena-network/idena-go/releases"
if [[ "$USER" == "root" ]]; then
        HOMEFOLDER="/root/idena-scripts"
 else
        HOMEFOLDER="/home/$USER/idena-scripts"
fi

CURRENTDIR=$(pwd)
cd $HOMEFOLDER

if [[ -z $(sudo -u root crontab -l | grep 'idenaupdate.sh') ]]; then
        sudo -u root crontab -l > cron
        echo -e "0 */1 * * * $HOMEFOLDER/idenaupdate.sh >/dev/null 2>&1" >> cron
        sudo -u root crontab cron
        rm cron
fi
echo "Create script file..."

echo "#!/bin/bash" > $SCRIPT_NAME
echo >> $SCRIPT_NAME
echo -e "GITPATH=$PATH_NAME" >> $SCRIPT_NAME
echo -e "RELEASES_PATH=$RPATH_NAME" >> $SCRIPT_NAME
echo 'DIR_NAME="idena-node-linux-"' >> $SCRIPT_NAME
echo 'CURRENTDIR=$(pwd)' >> $SCRIPT_NAME
echo -e "cd $HOMEFOLDER" >> $SCRIPT_NAME
echo 'if [ -d idena-go ]; then' >> $SCRIPT_NAME
echo '  cd idena-go' >> $SCRIPT_NAME
echo '  git fetch' >> $SCRIPT_NAME
echo '  else' >> $SCRIPT_NAME
echo '  git clone $GITPATH' >> $SCRIPT_NAME
#echo '  cd idena-go' >> $SCRIPT_NAME
echo 'fi' >> $SCRIPT_NAME
echo -e "chown -R $USER:$USER $HOMEFOLDER/idena-go" >> $SCRIPT_NAME
echo 'LATEST_TAG=$(git tag --sort=-creatordate | head -1)' >> $SCRIPT_NAME
echo 'cd ..' >> $SCRIPT_NAME
echo -n 'if [[ -z $' >> $SCRIPT_NAME
echo -n -e "($HOMEFOLDER/nknd -v | grep " >> $SCRIPT_NAME
echo '$LATEST_TAG) ]]; then' >> $SCRIPT_NAME

echo '  DIR_NAME+=${LATEST_TAG//v/}' >> $SCRIPT_NAME
echo '  if [ -f $DIR_NAME.zip ]; then rm $DIR_NAME.zip; fi' >> $SCRIPT_NAME
echo '  wget "$RELEASES_PATH/$LATEST_TAG/$DIR_NAME.zip"' >> $SCRIPT_NAME
echo '  unzip "$DIR_NAME.zip" >/dev/null 2>&1' >> $SCRIPT_NAME
#echo '  chmod +x $DIR_NAME/nkn*' >> $SCRIPT_NAME
echo '  cp -r $DIR_NAME/* .' >> $SCRIPT_NAME

echo '  rm -rf $DIR_NAME' >> $SCRIPT_NAME
echo '  rm $DIR_NAME.zip' >> $SCRIPT_NAME
echo 'fi' >> $SCRIPT_NAME
echo 'LATEST_TAG=$( ps -e | grep idenad | awk '{print $1}' )' >> $SCRIPT_NAME
#echo 'if [ -z $LATEST_TAG ]; then systemctl start nkn.service; fi' >> $SCRIPT_NAME
echo 'cd $CURRENTDIR' >> $SCRIPT_NAME

chmod +x $SCRIPT_NAME
cd $CURRENTDIR

