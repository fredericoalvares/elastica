export G5K_USER_PATH="$PROJECT_PATH/tmp/usr"
export G5K_PWD_PATH="$PROJECT_PATH/tmp/pwd"

export OPENSTACK_CAMPAIGN_HOME=~/openstack-campaign

export RESERVATION_NODES_FILE=$PROJECT_PATH/tmp/reservation_nodes
export KVLAN_NODES_FILE=$PROJECT_PATH/tmp/kvlan_nodes
export DEFAULT_NB_NODES=2
export DEFAULT_NB_HOURS=2



export PATH_IMAGE_VM=$HOME
export FILE_IMAGE_VM="ubuntu-12.04-server-cloudimg-amd64-disk1.img"
export numkavlan=4
export key=key
export sec_group="sec_group"

export name_image_LB="LoadBalancerImage"
export name_image_worker="WorkerImage"
export name_image_DB="DatabaseImage"

#doit etre executer en root au demarage d'une vm
export script_start_services="/root/start-services.sh" 

export PATH_KEYPAIR="/tmp"

export DEFAULT_LOCAL_CONF_PATH=/root

#NGINX
export NGINX_CONF_PATH=$DEFAULT_LOCAL_CONF_PATH
export NGINX_CONF=$NGINX_CONF_PATH/nginx.conf
export NGINX_TPL=$NGINX_CONF_PATH/nginx.tpl

#PHP-NGINX
export PHP_NGINX_CONF_PATH=$DEFAULT_LOCAL_CONF_PATH
export PHP_NGINX_CONF=$PHP_NGINX_CONF_PATH/nginx.conf
export PHP_NGINX_TPL=$PHP_NGINX_CONF_PATH/nginx.tpl

export WWW_ROOT="/root/www"


#DB
export DB_ROOT_USER="root"
export DB_ROOT_PASSWORD="toto"
export DB_USER="rubis"
export DB_PASSWORD="rubis"
export DB_NAME="rubis"
export DB_INFO_FILE="/tmp/dbinfo"
export DB_DEFAULT_HOST="localhost"
export DB_SCRIPT_PATH=$DEFAULT_LOCAL_CONF_PATH
export DB_DATA_SCRIPT=$DEFAULT_LOCAL_CONF_PATH/rubis.sql
export DB_GRANTS_SCRIPT=$DEFAULT_LOCAL_CONF_PATH/grants.sql


export LB_PORT=8080
export WORKER_PORT=8080

#periode a laquelle on log le system d'une vm en seconde
export PERIODE_LOG_SYSTEM=5

#periode a laquelle on log le nginx en seconde
export PERIODE_LOG_LB=20


export FILE_LOG_SYSTEM=$DEFAULT_LOCAL_CONF_PATH/system.log
export FILE_LOG_SYSTEM2=$DEFAULT_LOCAL_CONF_PATH/system2.log
export FILE_LOG_NGINX=$DEFAULT_LOCAL_CONF_PATH/access_nginx.log
export FILE_LOG_LB=$DEFAULT_LOCAL_CONF_PATH/nginx_report.log
export ADRESSE_IP_SERVER_REDIS=10.0.0.1

#this number should be great enough to 
#comprise all the log records since the last $PERIODE_LOG_LB
#and small enough to not compromise the collection performance

export NGINX_RECORDS_TO_READ=100


export FLAVOR_ID=2
export LB_FLAVOR_ID=2
#nombre d'instance par défaut
export NUMBER_INSTANCES=3


#export NUMBER_APPLICATIONS=2
export INJECTOR_NODES_FILE=$PROJECT_PATH/tmp/injectors.txt

#LOGSTASH

export LOGSTASH_FLUSH_PERIOD=60 #for modes
export LOGSTASH_FLUSH_PERIOD2=20


export LEVELS="0 1 2"
export DEFAULT_LEVEL="2"
export LEVEL_FILE="$DEFAULT_LOCAL_CONF_PATH/elasticity.param"

export TIER_LIST_PATH=/tmp

export TMP_FILE_LOG_CLOUD_STATE=/tmp/log_cloud_state

#temps de calme en secondes 
export TEMPS_DE_CALME=30

log_cloud_state () {
	$PROJECT_PATH/experiments/rubis_energy/scripts/getCloudState.sh $1 >> $TMP_FILE_LOG_CLOUD_STATE
}




