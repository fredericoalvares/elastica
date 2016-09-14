#!/bin/bash
# doit s'executer sur une machine virtuelle au démarage de celle ci

PROJECT_PATH=/share

source $PROJECT_PATH/common/util.sh

if ! [ -f $DEFAULT_LOCAL_CONF_PATH/name_tier.info ]
then
        echo "$DEFAULT_LOCAL_CONF_PATH/name_tier.info doit exister"
        exit 1
fi


logstash=logstash-1.4.2

#on demare le processus qui log periodiquement
$DEFAULT_LOCAL_CONF_PATH/collect_system_log.sh &
$DEFAULT_LOCAL_CONF_PATH/collect_vmstat_log.sh &
#on configure logstash.conf

NOM_DU_TIER=`cat $DEFAULT_LOCAL_CONF_PATH/name_tier.info`

cat $DEFAULT_LOCAL_CONF_PATH/shipper_system.conf | sed "s/@@@FILE_LOG_SYSTEM@@@/`echo $FILE_LOG_SYSTEM | tr '/' '@'`/" | sed "s/@@@NOM_DU_TIER@@@/$NOM_DU_TIER/" | sed "s/@@@ADRESSE_IP_SERVER_REDIS@@@/$ADRESSE_IP_SERVER_REDIS/" | tr '@' '/' > /tmp/tmp_logstash.conf
mv /tmp/tmp_logstash.conf $DEFAULT_LOCAL_CONF_PATH/logstash_system.conf

#to distinguish LB and worker
HN=$(hostname)
VM_NAME=${NOM_DU_TIER}"-vm-lb"

if [ "$HN" == "$VM_NAME" ]
then
# $DEFAULT_LOCAL_CONF_PATH/collect_lb_log.sh &

 cat $DEFAULT_LOCAL_CONF_PATH/shipper_nginx.conf | sed "s/@@@FILE_LOG_NGINX@@@/`echo $FILE_LOG_NGINX | tr '/' '@'`/" | sed "s/@@@NOM_DU_TIER@@@/$NOM_DU_TIER/" | sed "s/@@@FLUSH_INTERVAL@@@/$LOGSTASH_FLUSH_PERIOD/" | sed "s/@@@IGNORE_OLDER_THAN@@@/$LOGSTASH_FLUSH_PERIOD/" | sed "s/@@@CLEAR_INTERVAL@@@/$LOGSTASH_FLUSH_PERIOD/" | sed "s/@@@ADRESSE_IP_SERVER_REDIS@@@/$ADRESSE_IP_SERVER_REDIS/" | tr '@' '/' > /tmp/tmp_logstash.conf
 mv /tmp/tmp_logstash.conf $DEFAULT_LOCAL_CONF_PATH/logstash_nginx.conf

 cat $DEFAULT_LOCAL_CONF_PATH/shipper_nginx2.conf | sed "s/@@@FILE_LOG_NGINX@@@/`echo $FILE_LOG_NGINX | tr '/' '@'`/" | sed "s/@@@NOM_DU_TIER@@@/$NOM_DU_TIER/" | sed "s/@@@FLUSH_INTERVAL@@@/$LOGSTASH_FLUSH_PERIOD2/" | sed "s/@@@IGNORE_OLDER_THAN@@@/$LOGSTASH_FLUSH_PERIOD2/" | sed "s/@@@CLEAR_INTERVAL@@@/$LOGSTASH_FLUSH_PERIOD2/" | sed "s/@@@ADRESSE_IP_SERVER_REDIS@@@/$ADRESSE_IP_SERVER_REDIS/" | tr '@' '/' > /tmp/tmp_logstash.conf

  mv /tmp/tmp_logstash.conf $DEFAULT_LOCAL_CONF_PATH/logstash_nginx2.conf
 
 $DEFAULT_LOCAL_CONF_PATH/$logstash/bin/logstash agent -f "$DEFAULT_LOCAL_CONF_PATH/logstash_nginx.conf" > /root/stdout_logstash_nginx 2> /root/stderr_logstash_nginx &

  $DEFAULT_LOCAL_CONF_PATH/$logstash/bin/logstash agent -f "$DEFAULT_LOCAL_CONF_PATH/logstash_nginx2.conf" > /root/stdout_logstash_nginx2 2> /root/stderr_logstash_nginx2 &

fi

$DEFAULT_LOCAL_CONF_PATH/$logstash/bin/logstash agent -f "$DEFAULT_LOCAL_CONF_PATH/logstash_system.conf" > /tmp/stdout_logstash_system 2> /tmp/stderr_logstash_system &
