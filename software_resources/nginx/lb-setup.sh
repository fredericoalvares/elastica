#!/bin/bash

PROJECT_PATH=/share

while ! [ -e $PROJECT_PATH/common/util.sh  ]
do
	echo "Not found $PROJECT_PATH/common/util.sh"
	sudo mount -t nfs 10.0.0.1:/share /share
	sleep 1
done

source $PROJECT_PATH/common/util.sh

if [ "$#" -lt 2 ] 
then
#|| [ "$1" != "add" -a "$1" != "rem" ]; then
   echo "Usage: $0 port worker_1 worker_2 ... worker_n"
   exit 1
fi

PORT=$1
shift
WORKERS="$*"
#cp $NGINX_CONF $NGINX_CONF_BKP 

#if [ "$CMD" = "add"  ]; then
echo "Setting workers $WORKERS"

ADDED_SERVERS=
for i in $WORKERS; do
   ADDED_SERVERS=$ADDED_SERVERS'\tserver '$i';\n'
done

nb_proc=$(sudo grep ^proces /proc/cpuinfo | wc -l)

sed "s/@@@PORT@@@/$PORT/g" $NGINX_TPL | sed "s/@@@WORKERS@@@/$ADDED_SERVERS/g" | sed "s/@@@PROCESSES@@@/$nb_proc/g" > $NGINX_CONF

# sed -n '1h;1!H;${;g;s/\(upstream[^{]*{\)\([^}]*\)}/\1 \2'"$ADDED_SERVERS"'\n    }/g;p;}' $NGINX_TPL >  $NGINX_CONF
# mv $NGINX_CONF_TMP $NGINX_CONF
#else 
#  if [ "$CMD" = "rem"  ]; then
#    echo "Removing workers ${@:2}"

#    for i in $WORKERS; do
#      sed -i -e "s/server $i;//g" $NGINX_CONF
#    done
#  fi
#fi

if [ -z "`ps ax | grep $NGINX_CONF | grep -v grep`" ]  #|| ! [ -f /var/run/nginx.pid ]
then
  echo "Oops, nginx is not running... starting right now!"
  sudo nginx -c $NGINX_CONF
else
  echo "Reloading nginx conf file!"
  sudo nginx -s reload -c $NGINX_CONF
fi


#echo $1

