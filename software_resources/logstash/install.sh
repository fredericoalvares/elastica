#!/bin/bash

#instalation de logstash

if [ "`env|grep PROJECT_PATH`" = "" ]
then
	echo "PROJECT_PATH is not defined"
	exit 2
fi
source $PROJECT_PATH/software_resources/header_install.sh


directory=$PROJECT_PATH/software_resources/logstash
logstash=logstash-1.4.2

#on copie les fichiers logstash dans un autre dossier (le nfs est en lecture seule)
scp -i $PATH_KEYPAIR/id_rsa  $directory/*.* ubuntu@$ip_adress:$DEFAULT_LOCAL_CONF_PATH/ 
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo tar xvzf $DEFAULT_LOCAL_CONF_PATH/$logstash.tar.gz -C $DEFAULT_LOCAL_CONF_PATH"  # && sudo cp -r $logstash ~/"

rm -f /tmp/commandes

echo "$DEFAULT_LOCAL_CONF_PATH/start-logstash.sh &" >> /tmp/commandes

source $PROJECT_PATH/software_resources/footer_install.sh

#rm -f /tmp/commandes


