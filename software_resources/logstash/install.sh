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
#$DEFAULT_LOCAL_CONF_PATH/
#ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo cp $directory/$logstash.tar.gz $DEFAULT_LOCAL_CONF_PATH/"
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo tar xvzf $DEFAULT_LOCAL_CONF_PATH/$logstash.tar.gz" # && sudo cp -r $logstash ~/"

#ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo cp $directory/shipper_system.conf $DEFAULT_LOCAL_CONF_PATH/"
#ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo cp $directory/shipper_nginx.conf $DEFAULT_LOCAL_CONF_PATH/"
#ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo cp $directory/shipper_nginx2.conf $DEFAULT_LOCAL_CONF_PATH/"
#ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo cp $directory/indexer_logstash.conf $DEFAULT_LOCAL_CONF_PATH/"
#ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo cp $directory/em_logstash.conf $DEFAULT_LOCAL_CONF_PATH/"

#ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo cp $directory/start-logstash.sh $DEFAULT_LOCAL_CONF_PATH/"
#ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo cp $directory/collect_system_log.sh $DEFAULT_LOCAL_CONF_PATH/"
#ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo cp $directory/collect_lb_log.sh $DEFAULT_LOCAL_CONF_PATH/"
rm -f /tmp/commandes
#echo "$DEFAULT_LOCAL_CONF_PATH/$logstash/bin/logstash agent -f $DEFAULT_LOCAL_CONF_PATH/shipper_system.conf" >> /tmp/commandes

echo "$DEFAULT_LOCAL_CONF_PATH/start-logstash.sh &" >> /tmp/commandes

source $PROJECT_PATH/software_resources/footer_install.sh

rm -f /tmp/commandes


