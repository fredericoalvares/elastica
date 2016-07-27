#!/bin/bash

#doit être executé  sur le cloud controler

#instalation de java

if [ "`env|grep PROJECT_PATH`" = "" ]
then
	echo "PROJECT_PATH is not defined"
	exit 2
fi
source $PROJECT_PATH/software_resources/header_install.sh


ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo apt-get -y update;sudo apt-get -y install openjdk-7-jre-headless"

ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo update-alternatives --set java  /usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java"
