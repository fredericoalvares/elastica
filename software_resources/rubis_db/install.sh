#!/bin/bash

#doit être executé  sur le cloud controler

#instalation de la bd rubis

if [ "`env|grep PROJECT_PATH`" = "" ]
then
	echo "PROJECT_PATH is not defined"
	exit 2
fi
source $PROJECT_PATH/software_resources/header_install.sh

scp -i $PATH_KEYPAIR/id_rsa $PROJECT_PATH/software_resources/rubis_db/*.sql ubuntu@$ip_adress:$DB_SCRIPT_PATH/ 

#ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo cp  $PROJECT_PATH/software_resources/rubis_db/*.sql $DB_SCRIPT_PATH/"
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo mysqladmin --user=$DB_ROOT_USER --password=$DB_ROOT_PASSWORD create $DB_NAME"
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo mysql --user=$DB_ROOT_USER  --password=$DB_ROOT_PASSWORD rubis < $DB_DATA_SCRIPT"
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo mysql --user=$DB_ROOT_USER  --password=$DB_ROOT_PASSWORD < $DB_GRANTS_SCRIPT"




