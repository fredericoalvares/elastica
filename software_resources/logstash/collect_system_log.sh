#!/bin/bash

PROJECT_PATH=/share

source $PROJECT_PATH/common/util.sh

rm -f $FILE_LOG_SYSTEM
myIp=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/');
while true
do 
	
	host_ip=$myIp
        hname=$(hostname)
	timestamp=$(date +%s)
	total_mem=`top -b -n 1 | head -4 | tail -1 | tr -s ' ' | cut -d ' ' -f2 | sed "s/k//"`
	used_mem=`top -b -n 1 | head -4 | tail -1 | tr -s ' ' | cut -d ' ' -f4 | sed "s/k//"`
	mem=`bc -l <<< "( $used_mem/$total_mem ) * 100" | cut -c 1-4`
	cpu_idle=`top -b -n 1 | head -3 | tail -1 | tr -s ' ' | cut -d ' ' -f 5 | cut -d '%' -f1`
	cpu=`bc -l <<< "100 - $cpu_idle"`
	echo "{\"timestamp\":"$timestamp",\"host_name\":"$hname",\"ip\":\""$host_ip"\",\"cpu\":"$cpu",\"mem\":"$mem"}" >> $FILE_LOG_SYSTEM
	sleep $PERIODE_LOG_SYSTEM


done







