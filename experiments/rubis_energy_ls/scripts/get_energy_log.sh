
if ! [ -d /share ] || ! [ -f /root/openrc ]
then
     echo "This script should be executed on the controller."
     exit 1
fi

if [ $# -lt 4 ] 
then
    echo "Usage: $0 <start_timestamp> <end_timestamp> <output_log_path> <node1> <node2>..."
    exit 1 
fi


source $PROJECT_PATH/common/util.sh

if ! [ -f $G5K_USER_PATH -a -f $G5K_PWD_PATH ]
then
    echo "Error: Username or password not stored!"
    exit 1
fi

G5K_PWD=$(cat $G5K_PWD_PATH | base64 --decode)
G5K_USER=$(cat $G5K_USER_PATH)



START_LOG_TIME=$1
END_LOG_TIME=$2
OUTPUT_LOG_PATH=$3

echo $0 $@

shift 3

SYEAR=$(date -d @$START_LOG_TIME +%Y)
SMONTH=$(date -d @$START_LOG_TIME +%m)
SDAY=$(date -d @$START_LOG_TIME +%d)
SHOUR=$(date -d @$START_LOG_TIME +%H)
SMINUTE=$(date -d @$START_LOG_TIME +%M)
SSECOND=$(date -d @$START_LOG_TIME +%S)

EYEAR=$(date -d @$END_LOG_TIME +%Y)
EMONTH=$(date -d @$END_LOG_TIME +%m)
EDAY=$(date -d @$END_LOG_TIME +%d)
EHOUR=$(date -d @$END_LOG_TIME +%H)
EMINUTE=$(date -d @$END_LOG_TIME +%M)
ESECOND=$(date -d @$END_LOG_TIME +%S)

nodes=$(echo "$@" | sed -e 's/\.lyon\.grid5000\.fr//g')

echo "nodes : " $nodes

i=0
node_params=
for node in $nodes
do
  node_params=$node_params"&node[$i]=$node"
  i=`expr $i + 1`
done
echo $node_params
WATTMETER_URL="https://intranet.grid5000.fr/supervision/lyon/wattmetre"

export https_proxy='http://proxy:3128'
export https_proxy=$http_proxy

#echo "start-year=${SYEAR}&start-month=${SMONTH}&start-day=${SDAY}&start-hour=${SHOUR}&start-minute=${SMINUTE}&start-second=${SSECOND}&end-year=${EYEAR}&end-month=${EMONTH}&end-day=${EDAY}&end-hour=${EHOUR}&end-minute=${EMINUTE}&end-second=${ESECOND}}${node_params}&incr=1"
#exit;

curl -u $G5K_USER:$G5K_PWD -d "start-year=${SYEAR}&start-month=${SMONTH}&start-day=${SDAY}&start-hour=${SHOUR}&start-minute=${SMINUTE}&start-second=${SSECOND}&end-year=${EYEAR}&end-month=${EMONTH}&end-day=${EDAY}&end-hour=${EHOUR}&end-minute=${EMINUTE}&end-second=${ESECOND}${node_params}&incr=1" $WATTMETER_URL/traitement.php > $OUTPUT_LOG_PATH/tmp_html

rm $OUTPUT_LOG_PATH/*.watt.log

for node in $nodes
do
   LOG_PATH=$(sed -n "s/.*href\=\"\.\(\/userlogs.*$node.dat\)\".*$/\1/p" $OUTPUT_LOG_PATH/tmp_html)
   echo $LOG_PATH
   wget --http-user=$G5K_USER --http-password=$G5K_PWD $WATTMETER_URL/$LOG_PATH -O $OUTPUT_LOG_PATH/$node.watt.log
done
#
unset http_proxy
unset https_proxy


rm $OUTPUT_LOG_PATH/tmp_html


