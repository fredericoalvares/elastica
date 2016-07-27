if ! [ -d /share ] || ! [ -f /root/openrc ]
then
	echo "doit etre execute sur le cloud controler"
	exit 1
fi


cd $PROJECT_PATH

source $PROJECT_PATH/common/util.sh

usage="$0 <ip_adress>"

if [ $# -ne 1 ]
then
	echo $usage
	exit 1
fi

ip_adress=$1
