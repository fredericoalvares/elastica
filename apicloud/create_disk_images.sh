#!/bin/bash

#doit être executé  sur le cloud controler

#instalation du nfs

if ! [ -d /share ] || ! [ -f /root/openrc ]
then
	echo "doit etre execute sur le cloud controler"
	exit 1
fi

if [ "`env|grep PROJECT_PATH`" = "" ]
then
	echo "PROJECT_PATH is not defined"
	exit 2
fi
cd $PROJECT_PATH

source $PROJECT_PATH/common/util.sh

usage="$0 <LB|w|db>"

if [ $# -ne 1 ]
then
	echo $usage
	exit 1
fi

type=$1

if [ "$type" = "w" ]
then
	#if it is a worker, we need to install php, rubbisa and logstash
	#soft_to_install="nfs_client java fib logstash"
	soft_to_install="php rubis java logstash"
	name_image=$name_image_worker
elif [ "$type" = "LB" ]
then
	#sinon si load balancer on a besoin de java et de nginx 
	soft_to_install="nginx java logstash"
	name_image=$name_image_LB
elif [ "$type" = "db" ]
then
	soft_to_install="mysql rubis_db logstash"
        name_image=$name_image_DB
fi


if [ "`nova image-list | grep $name_image`" != "" ]
then
	#on efface l'image pour laisser place à la nouvelle
	nova image-delete $name_image
fi


name_tmpvm=basic_tmp

nova boot --nic net-id=$(neutron net-show -c id -f value private) --flavor 2 --security-groups $sec_group --image "Ubuntu 12.04"  --key-name $key --poll $name_tmpvm

#ip_adress=`nova list | grep "$name_tmpvm" | tr '|' ' '| tr -s ' '| cut -d ' ' -f7 | cut -d '=' -f2`

rm $HOME/.ssh/known_hosts

ip_adress=$(nova floating-ip-create public |grep public | tr '|' ' '| tr -s ' '| cut -d ' ' -f3)

echo "Attaching $ip_adress to $name_tmpvm"
nova add-floating-ip $name_tmpvm $ip_adress

echo -n "trying to connect to $name_tmpvm ($ip_adress)"
ssh -o "StrictHostKeyChecking no" ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "echo connection succeeded" 2> /dev/null
ok=$?
while [ $ok -ne 0 ]
do
	echo -n "."
	sleep 3
	ssh -o "StrictHostKeyChecking no" ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "echo connection succeeded" 2> /dev/null
	ok=$?
done

ssh -i /tmp/id_rsa ubuntu@$ip_adress "(echo '127.0.0.1 basic-tmp' ; cat /etc/hosts) > tmp"
ssh -i /tmp/id_rsa ubuntu@$ip_adress "cat tmp > /etc/hosts"

#ssh -o "StrictHostKeyChecking no" ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sed '2i127.0.0.1 '\$(hostname) /etc/hosts > ~/hosts;mv ~/hosts /etc/hosts"
ssh -o "StrictHostKeyChecking no" ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa 'sudo touch /etc/apt/apt.conf.d/proxy-guess'
ssh -o "StrictHostKeyChecking no" ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa 'sudo chmod 777 /etc/apt/apt.conf.d/proxy-guess'
ssh -o "StrictHostKeyChecking no" ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa '(echo Acquire::http::Proxy \"http://proxy.nancy.grid5000.fr:3128\"\; > /etc/apt/apt.conf.d/proxy-guess)'



ssh -o "StrictHostKeyChecking no" ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo rm -rf $script_start_services"
ssh -o "StrictHostKeyChecking no" ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo touch $script_start_services"
ssh -o "StrictHostKeyChecking no" ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo chmod 777 /root"
ssh -o "StrictHostKeyChecking no" ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo chmod 777 $script_start_services"

ssh -o "StrictHostKeyChecking no" ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo mkdir -p /share;sudo chmod 777 /share"
scp -i $PATH_KEYPAIR/id_rsa -r $PROJECT_PATH/common ubuntu@$ip_adress:/share

#instalation des softs
for soft in $soft_to_install
do
	echo "installing soft $soft on $ip_adress ..."
	directory=$PROJECT_PATH/software_resources/$soft
	$directory/install.sh $ip_adress
done


ssh -o "StrictHostKeyChecking no" ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo sync"

#on créer un snapshot de l'image de la vm temporaire
nova image-create --poll $name_tmpvm $name_image


#on efface la machine temporaire

check=0
counter=0
while [ $check -ne 1 ]
do
    nova delete $name_tmpvm
    sleep 5
    deleted=$(nova list | grep $name_tmpvm)
    if [ -z "$deleted" ]
    then 
       check=1
    else 
       if [ $counter -gt 3 ]
       then
          echo "Error:  tried to delete VM 3 times with no success!"
          exit 0   
       else
	  nova reset-state $name_tmpvm
          counter=`expr $counter + 1`
       fi
    fi
done

