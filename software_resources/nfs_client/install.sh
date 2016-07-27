#!/bin/bash

#doit être executé  sur le cloud controler

#instalation de nfs_client

if [ "`env|grep PROJECT_PATH`" = "" ]
then
	echo "PROJECT_PATH is not defined"
	exit 2
fi
source $PROJECT_PATH/software_resources/header_install.sh

ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo apt-get -y update"
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo apt-get -y install portmap"
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo apt-get -y install nfs-common"
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo mkdir /share"
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo chmod 777 /share"

cmd="mount -t nfs 10.0.0.1:/share /share"
#on monte le nfs
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo $cmd"

#on sauvegarde dans le script de démarage
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo echo \"$cmd\" >> $script_start_services"
