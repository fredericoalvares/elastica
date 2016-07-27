#!/bin/bash

#doit être executé  sur le cloud controler

echo "################################"
echo "##### Installing fib.jar #######"
echo "################################"

if [ "`env|grep PROJECT_PATH`" = "" ]
then
	echo "PROJECT_PATH is not defined"
	exit 2
fi
source $PROJECT_PATH/software_resources/header_install.sh


#ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo apt-get -y install nginx-full"
directory=$PROJECT_PATH/software_resources/fib
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo cp -r $directory $DEFAULT_LOCAL_CONF_PATH/"
cmd="java -Dport=8080 -Dfilepath=$DEFAULT_LOCAL_CONF_PATH/fib/elasticity.param -Dfib.L=1000 -Dfib.M=10000 -Dfib.H=100000 -jar $DEFAULT_LOCAL_CONF_PATH/fib/fib.jar > $DEFAULT_LOCAL_CONF_PATH/fib/log.txt &"

ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "ls /home/ubuntu/"


#on demare nginx
#ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo $cmd"

#sauvegarde dans le script de démarage
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo echo \"$cmd\" >> $script_start_services"
