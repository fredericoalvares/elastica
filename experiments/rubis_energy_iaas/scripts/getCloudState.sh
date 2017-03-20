#!/bin/bash

if ! [ -d /share ] || ! [ -f /root/openrc ]
then
	echo "doit etre execute sur le cloud controler"
	exit 2
fi

action=$1
TIER=$2

TIER_FILE="/tmp/$TIER"

cd $PROJECT_PATH

source $PROJECT_PATH/common/util.sh

#nb_vm=`nova list | grep ACTIVE | tr '|' ' ' | tr -s ' ' | cut -d ' ' -f 3 | wc -l `
#nb_worker=`expr $nb_vm - 1`

WORKERS=( $(grep workers= ${TIER_FILE} | cut -d '=' -f2) )

nb_worker=${#WORKERS[@]}


#ip_adress_worker=`nova list | grep private | grep -v 'LB' | grep -v 'db-rubis' | tr '|' ' ' | tr -s ' ' | head -1 | cut -d ' ' -f8`

ip_adress_worker=`nova list | grep private | grep ${WORKERS[0]} | tr '|' ' ' | tr -s ' ' | head -1 | cut -d ' ' -f8`
#ip_adress_worker=`nova list | grep 'novanetwork' | grep -v 'LB' | grep -v 'db-rubis' | tr  '|' ' ' | tr -s ' ' | head -1 | cut -d ' ' -f 5 | cut -d '=' -f2`
level_appli=`ssh -o "StrictHostKeyChecking no" ubuntu@$ip_adress_worker -i $PATH_KEYPAIR/id_rsa "sudo cat $LEVEL_FILE"`	
#on affiche sur lasortie standard le level_appli et nb_worker
echo `date +%s%N | cut -b1-13 ` $nb_worker $level_appli $action
