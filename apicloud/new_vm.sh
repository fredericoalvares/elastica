#!/bin/bash

#doit être executé  sur le cloud controler

if ! [ -d /share ] || ! [ -f /root/openrc ]
then
	echo "doit etre execute sur le cloud controler"
	exit 1
fi
export PROJECT_PATH=/share
cd $PROJECT_PATH

source $PROJECT_PATH/common/util.sh

usage="$0 <vm_flavor> <name_vm> <LB|w|db> <name_tier> [<host>]"

if [ $# -lt 4 ]
then
	echo $usage
	exit 1
fi

flavor=$1
name_vm=$2
type=$3
name_tier=$4

host=$5

nova_cmd() {
   ok=0
   count=0
   while [ $ok -eq 0 ]
   do
      nova $@
      rc=$?
      if [ $rc -eq 0 ]
      then 
        ok=1
      else
        sleep 3
        count=`expr $count + 1`
        if  [ $count -eq 4 ]
        then 
           echo "******* ERROR: $0 command has failed more than 3 times ********" 
	   exit $rc 
        fi
      fi
   done
}

if [ "$type" = "LB" ]
then
	name_image=$name_image_LB
elif [ "$type" = "w" ]
then	
	name_image=$name_image_worker	
elif [ "$type" = "db" ]
then	
	name_image=$name_image_DB	
else
	echo $usage
	exit 2
fi


if [ -z "`nova_cmd image-list | grep $name_image`" ]
then
	#il faut creer l'image disque en question
	$PROJECT_PATH/apicloud/create_disk_images.sh $type
fi
id_image=`nova_cmd image-list | grep $name_image | tr '|' ' '| tr -s ' '| cut -d ' ' -f2`

#if [ -z "`nova image-list | grep $name_image`" ]
#then
#	#il faut creer l'image disque en question
#	$PROJECT_PATH/apicloud/create_disk_images.sh $type
#fi

#netid=$(neutron subnet-list | grep "public" |tr '|' ' '| tr -s ' '| cut -d ' ' -f2)
start=`date +%s%N | cut -b1-13`

host_option=

if ! [ -z "$host" ]
then
 host_option=" --availability-zone nova:$host"
fi


#ip_adress=`nova list | grep "$name_vm" | tr '|' ' '| tr -s ' '| cut -d ' ' -f5 | cut -d '=' -f2`

check=0
count=0
while [ $check -ne 1 ] 
do
    nova_cmd boot --nic net-id=$(neutron net-show -c id -f value private) --flavor $flavor --security-groups $sec_group --image $id_image  --key-name $key --poll $name_vm $host_option

    running=`nova_cmd list | grep "$name_vm" | tr '|' ' '| tr -s ' '| cut -d ' ' -f4`

    if  [ "$running" == "ACTIVE" ]
    then
    	ip_adress=$(nova_cmd floating-ip-create public |grep public | tr '|' ' '| tr -s ' '| cut -d ' ' -f3)

	echo "Attaching $ip_adress to $name_vm"
	nova_cmd add-floating-ip $name_vm $ip_adress
        
	rm -f $HOME/.ssh/known_hosts
	echo -n "trying to connect to $name_vm ($ip_adress)"
	ssh -o "StrictHostKeyChecking no" ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "echo connection succeeded" 2> /dev/null
	ok=$?
	while [ $ok -ne 0 ]
	do
    	     echo -n "."
	     sleep 3
	     ssh -o "StrictHostKeyChecking no" ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "echo connection succeeded" 2> /dev/null
	     ok=$?
	done
        check=1
    elif [ -n "$running" ] 
    then  
        nova_cmd delete $name_vm 
    fi
    
    ## We retry 5 times 
    if [ $check -eq 0 ]
    then  
        count=`expr $count + 1`
    	if [ $count -gt 5 ]
    	then
    	   exit 0  
    	fi
    fi 
done


#il faut spécifier le nom du tier à la machine dans le fichier $DEFAULT_LOCAL_CONF_PATH/name_tier.info
#ssh -i /tmp/id_rsa ubuntu@$ip_adress "(echo '127.0.0.1 $name_vm' ; cat /etc/hosts) > tmp"

ssh -i /tmp/id_rsa ubuntu@$ip_adress "sed 's/basic-tmp/'\$(hostname)'/g' /etc/hosts > tmp" 
ssh -i /tmp/id_rsa ubuntu@$ip_adress "cat tmp > /etc/hosts"

ssh -o "StrictHostKeyChecking no" ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo echo $name_tier > $DEFAULT_LOCAL_CONF_PATH/name_tier.info"

ssh -o "StrictHostKeyChecking no" ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "rm -f /tmp/flag && touch /tmp/flag"
ssh -o "StrictHostKeyChecking no" ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo $script_start_services && rm -f /tmp/flag" &

#on ferme la connexion
echo -n "closing conection"
while [ `ssh -o "StrictHostKeyChecking no" ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "[ -e /tmp/flag ]"`  ]
do
	echo -n "."
done
tokill=`ps aux | grep  $script_start_services | grep -v "grep" | tr -s ' ' | cut -d ' ' -f 2`
kill -9 $tokill
echo -n "conection closed"


stop1=`date +%s%N | cut -b1-13`


echo "temps de demarage = `expr $stop1 - $start`"
