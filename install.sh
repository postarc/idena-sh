#!/bin/bash

DAEMON_FILE='idena-node'

if [[ "$USER" == "root" ]]; then
        HOMEFOLDER="/root/idena"
 else
        HOMEFOLDER="/home/$USER/idena"
fi

CURRENTDIR=$(pwd)
if [ ! -d $HOMEFOLDER ]; then mkdir $HOMEFOLDER; fi

sudo ufw allow 40403
sudo ufw allow 40404
