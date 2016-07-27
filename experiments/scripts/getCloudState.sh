#!/bin/bash

if ! [ -d /share ] || ! [ -f /root/openrc ]
then
	echo "doit etre execute sur le cloud controler"
	exit 2
fi

action=$1

cd $PROJECT_PATH

source $PROJECT_PATH/common/util.sh

nb_vm=`nova list | grep novanetwork | grep ACTIVE | tr '|' ' ' | tr -s ' ' | cut -d ' ' -f 3 | wc -l `
nb_worker=`expr $nb_vm - 1`
ip_adress_worker=`nova list | grep 'novanetwork' | grep -v 'LB' | tr  '|' ' ' | tr -s ' ' | head -1 | cut -d ' ' -f 5 | cut -d '=' -f2`
level_appli=`ssh -o "StrictHostKeyChecking no" ubuntu@$ip_adress_worker -i $PATH_KEYPAIR/id_rsa "sudo cat $LEVEL_FILE"`	
#on affiche sur lasortie standard le level_appli et nb_worker
echo `date +%s%N | cut -b1-13 ` $nb_worker $level_appli $action
