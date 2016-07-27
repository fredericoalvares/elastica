#!/bin/bash

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

if [ "$#" -ne 2 ]; then
   echo "Usage: $0 [ + | - | level ] tier"
   exit 1
fi

sens=$1
TIER=$2
TIER_FILE="/tmp/$TIER"

if ! [ -f "$TIER_FILE" ]; then
  echo "Tier not found!"
  exit 1
fi

echo "Executing $0 in sens $sens"

re='^[0-9]+$'

if [ "$sens" = "+" ]
then
	$PROJECT_PATH/apicloud/scale-saas.sh down $TIER
elif [ "$sens" = "-" ]
then
	$PROJECT_PATH/apicloud/scale-saas.sh up $TIER
elif [[ $sens =~ $re ]]; then
	$PROJECT_PATH/apicloud/scale-saas.sh $sens $TIER
fi
