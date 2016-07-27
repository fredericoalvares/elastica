#!/bin/bash

echo "################################"
echo "##### Installing Rubbis #######"
echo "################################"

if [ "`env|grep PROJECT_PATH`" = "" ]
then
	echo "PROJECT_PATH is not defined"
	exit 2
fi
source $PROJECT_PATH/software_resources/header_install.sh

scp -i $PATH_KEYPAIR/id_rsa $PROJECT_PATH/software_resources/rubis/w-setup.sh ubuntu@$ip_adress:$DEFAULT_LOCAL_CONF_PATH/ 
scp -i $PATH_KEYPAIR/id_rsa -r $PROJECT_PATH/software_resources/rubis/PHP ubuntu@$ip_adress:$WWW_ROOT/ 

#ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo cp $PROJECT_PATH/software_resources/rubis/w-setup.sh $DEFAULT_LOCAL_CONF_PATH/;sudo cp -r $PROJECT_PATH/software_resources/rubis/PHP $WWW_ROOT/;sudo echo \"$DEFAULT_LEVEL\" > $LEVEL_FILE"

ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo echo \"$DEFAULT_LEVEL\" > $LEVEL_FILE"




#cmd="service php5-fpm start service nginx start" 

#ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "ls /home/ubuntu/"


#on demare nginx
#ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo $cmd"

#sauvegarde dans le script de démarage
#ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo echo \"$cmd\" >> $script_start_services"
