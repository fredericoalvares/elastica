#!/bin/bash

if ! [ -d /share ] || ! [ -f /root/openrc ]
then
	echo "doit etre execute sur le cloud controler"
	exit 2
fi

running=`ps aux | grep init_event.sh | grep -v grep`

if ! [ -z "$running" ]
then
	
	echo "$0 is still running : kill it before" 
	exit 1
fi

while true
do
	nc -l 12345 | $PROJECT_PATH/elasticity_manager/init_event.sh  
done > /tmp/em_server.stdout 2> /tmp/em_server.stderr &
