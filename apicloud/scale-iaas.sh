#!/bin/bash

if ! [ -d /share ] || ! [ -f /root/openrc ]
then
     echo "doit etre execute sur le cloud controler"
     exit 1
fi

export PROJECT_PATH=/share
cd $PROJECT_PATH

source $PROJECT_PATH/common/util.sh



if [ "$#" -lt 2 ] || [ "$1" != "out" -a "$1" != "in" ]; then
   echo "Usage: $0 out | in tier"
   exit 1
fi

CMD=$1
TIER=$2
host=$3


TIER_FILE="$TIER_LIST_PATH/$TIER"

if [ -f "$TIER_FILE" ]; then
  WORKERS=$(grep workers= ${TIER_FILE} | cut -d '=' -f2) 
  echo $WORKERS
else
  if [ "$CMD" = "in" ]; then
     echo "Tier not found!"
     exit 1
  fi

  WORKERS=
fi
lb_ip_address=
lb_vm_name=$TIER'_VM_LB'
if [ "$CMD" = "out"  ]; then
   echo "Scaling out tier "$TIER " with "$NUMBER_INSTANCES "instances of flavor " $FLAVOR_ID 

   if [ -f "$DB_INFO_FILE" ]
   then
     DB_HOST=$(cat $DB_INFO_FILE) 
   else
     DB_HOST=$DB_DEFAULT_HOST
   fi
 
   for i in `seq 1 $NUMBER_INSTANCES`
   do
      vm_name=$TIER'_VM'$(date +"%s")$i
      echo "Creating $vm_name / flavor "$FLAVOR_ID
      $PROJECT_PATH/apicloud/new_vm.sh $FLAVOR_ID $vm_name w $TIER $host #&
      pids[`expr $i - 1`]=$!
      WORKERS=$WORKERS' '$vm_name
   done
   for i in `seq 1 $NUMBER_INSTANCES`
   do
      wait ${pids[`expr $i - 1`]}
   done
   ip_addresses=
   for i in $WORKERS
   do
      #ip_adress=`nova list | grep "$i" | tr '|' ' '| tr -s ' '| cut -d ' ' -f5 | cut -d '=' -f2`

      ip_adress=`nova list | grep "$i" | tr '|' ' '| tr -s ' '| cut -d ' ' -f8`
   
      private_ip_address=`nova list | grep "$i" | tr '|' ' '| tr -s ' '| cut -d ' ' -f7 | cut -d '=' -f2 | cut -d ',' -f1`
   
      ssh -o "StrictHostKeyChecking no" ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo /root/w-setup.sh $DB_HOST"
#      ip_addresses=$ip_addresses' '$ip_adress':'$WORKER_PORT
     
      ip_addresses=$ip_addresses' '$private_ip_address':'$WORKER_PORT

   done



   if ! [ -f "$TIER_FILE" ]; then
      echo "Tier not found, creating a LB"
      $PROJECT_PATH/apicloud/new_vm.sh $FLAVOR_ID $lb_vm_name LB $TIER $host
   fi
   #lb_ip_address=`nova list | grep "$lb_vm_name" | tr '|' ' '| tr -s ' '| cut -d ' ' -f5 | cut -d '=' -f2`
   lb_ip_address=`nova list | grep "$lb_vm_name" | tr '|' ' '| tr -s ' '| cut -d ' ' -f8`
   
   echo $ip_addresses
   echo "workers="$WORKERS > $TIER_FILE
   ssh -o "StrictHostKeyChecking no" ubuntu@$lb_ip_address -i $PATH_KEYPAIR/id_rsa "/root/lb-setup.sh $LB_PORT $ip_addresses"
else
   
   if [ "`echo $WORKERS | tr -s ' ' | wc -w`" -eq 1 ] #on ne fait pas le scale in si on a qu'un seul worker
   then
   	exit 0
   fi
   echo "Scaling in tier "$TIER " with "$NUMBER_INSTANCES "instances of flavor " $FLAVOR_ID
   list=( $WORKERS )   
  
   if [ ${#list[@]} -gt $NUMBER_INSTANCES ]
   then  
       WORKERS_TO_DELETE="${list[@]:0:$NUMBER_INSTANCES}"
       echo "{debug} WORKERS_TO_DELETE=$WORKERS_TO_DELETE"
	WORKERS="${list[@]:$NUMBER_INSTANCES}"
       echo "{debug} WORKERS=$WORKERS"
       ip_addresses=
       for i in $WORKERS
       do
        # ip_adress=`nova list | grep "$i" | tr '|' ' '| tr -s ' '| cut -d ' ' -f5 | cut -d '=' -f2`

#         ip_adress=`nova list | grep "$i" | tr '|' ' '| tr -s ' '| cut -d ' ' -f8`
 
         ip_adress=`nova list | grep "$i" | tr '|' ' '| tr -s ' '| cut -d ' ' -f7 | cut -d '=' -f2 | cut -d ',' -f1`
         ip_addresses=$ip_addresses' '$ip_adress':'$WORKER_PORT
       done
       echo "{debug} ip_addresses=$ip_addresses"
       #lb_ip_address=`nova list | grep "$lb_vm_name" | tr '|' ' '| tr -s ' '| cut -d ' ' -f5 | cut -d '=' -f2`

       lb_ip_address=`nova list | grep "$lb_vm_name" | tr '|' ' '| tr -s ' '| cut -d ' ' -f8`
       echo "{debug} lb_ip_address=$lb_ip_address"
	  ssh -o "StrictHostKeyChecking no" ubuntu@$lb_ip_address -i $PATH_KEYPAIR/id_rsa "sudo /root/lb-setup.sh $LB_PORT $ip_addresses"
       echo "workers="$WORKERS > $TIER_FILE
   else
       #no worker left
       WORKERS_TO_DELETE=$WORKERS
      
      # lb_vm_name=$TIER'_VM_LB'
       echo "deleting lb $lb_vm_name"
       
       nova delete $lb_vm_name
       rm $TIER_FILE
   fi

   #delete workers
   for i in $WORKERS_TO_DELETE
   do
       echo "deleting $i"
       nova delete $i
        while ! [ -z "`nova list | grep $i`" ]
	   do
		echo -n "."
	   done
       echo "$i deleted"
   done
fi

