#!/bin/bash

#doit être executé  sur le cloud controler

#instalation de jetty

if [ "`env|grep PROJECT_PATH`" = "" ]
then
	echo "PROJECT_PATH is not defined"
	exit 2
fi
source $PROJECT_PATH/software_resources/header_install.sh

directory=$PROJECT_PATH/software_resources/jetty
jetty=jetty-distribution-9.2.10.v20150310

#on copie les fichiers jetty dans un autre dossier (le nfs est en lecture seule)
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo cp $directory/$jetty.tar.gz $DEFAULT_LOCAL_CONF_PATH/"
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo tar xvzf /root/$jetty.tar.gz && sudo cp -r $jetty $DEFAULT_LOCAL_CONF_PATH/"


cmd="/root/$jetty/bin/jetty.sh start"
#on démare jetty
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo $cmd"

#on sauvegarde dans le script de démarage
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo echo \"$cmd\" >> $script_start_services"


