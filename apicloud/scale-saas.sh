#!/bin/bash

function indexOf () {
   list=( "${@:2}" )
   i=0
   if  [ ${#list[@]} -lt 0 ]; then
        return -1
   fi
   while [ $i -lt  ${#list[@]} -a  "${list[$i]}" != "$1" ]; do
	i=`expr $i + 1`
   done
   #echo $i
   if [ $i -lt  ${#list[@]} ]; then
        return $i
   else
        return -1
   fi
}


if ! [ -d /share ] || ! [ -f /root/openrc ]
then
     echo "doit etre execute sur le cloud controler"
     exit 1
fi

export PROJECT_PATH=/share
cd $PROJECT_PATH

source $PROJECT_PATH/common/util.sh

#LEVELS="L M H"

#LEVEL_FILE="~/fib/elasticity.param"

re='^[0-9]+$'

if [ "$#" -ne 2 ] || ! [[ "$1" = "up" || "$1" = "down" || $1 =~ $re ]]; then
   echo "Usage: $0 up | down tier"
   exit 1
fi

CMD=$1
TIER=$2
TIER_FILE="/tmp/$TIER"

if [ -f "$TIER_FILE" ]; then
  WORKERS=$(grep workers= ${TIER_FILE} | cut -d '=' -f2) 
#  echo $WORKERS
else
  echo "Tier not found!"
  exit 1
fi
level_arr=( $LEVELS )



for w in $WORKERS
do
#   ip_address=`nova list | grep "$w" | tr '|' ' '| tr -s ' '| cut -d ' ' -f5 | cut -d '=' -f2`
   ip_address=`nova list | grep "$w" | tr '|' ' '| tr -s ' '| cut -d ' ' -f8`
   ssh -o "StrictHostKeyChecking no" ubuntu@$ip_address -i $PATH_KEYPAIR/id_rsa "sudo chmod a+w $LEVEL_FILE"
   
   next_level=
   if [[ $CMD =~ $re ]]; then
      next_level=$CMD
   else
      curr_level=$(ssh -o "StrictHostKeyChecking no" ubuntu@$ip_address -i $PATH_KEYPAIR/id_rsa "sudo cat $LEVEL_FILE")
      echo "Current quality level is $curr_level [worker $w]"
      indexOf $curr_level $LEVELS
      idx=$?
 
      if [ "$CMD" = "up"  ]; then
         idx=`expr $idx + 1`
      else 
         idx=`expr $idx - 1`
      fi
      
      if [ $idx -ge 0 -a $idx -lt  ${#level_arr[@]} ]; then
         next_level=${level_arr[$idx]}
      else
         echo "Already in the minimum/maximum level : nothing to do! [worker $w]"         
      fi
   fi
   
   if ! [ -z "$next_level" ]
   then
      echo "Setting quality level to $next_level [worker $w :  $ip_address]"
      ssh -o "StrictHostKeyChecking no" ubuntu@$ip_address -i $PATH_KEYPAIR/id_rsa "sudo echo $next_level > $LEVEL_FILE"
   fi
done
