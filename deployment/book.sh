#!/bin/sh

NB_NODES=$DEFAULT_NB_NODES
HOURS=$DEFAULT_NB_HOURS

# No default cluster
CLUSTER=default
DATE=
SLEEP=3

if [ "`env|grep PROJECT_PATH`" = "" ]
then
        echo "PROJECT_PATH is not defined, using ~/elastica"
        export PROJECT_PATH=~/elastica
fi

source $PROJECT_PATH/common/util.sh

function usage {
        echo "Get nodes on g5k. A file '$RESERVATION_NODES_FILE' with the name of deployed nodes is created. Options:
                -c, the cluster
                -h, this help
                -l, display the submission default values
                -n, the number of nodes
                -r, schedule the reservation 'YYYY-MM-DD HH:MM:SS'
                -t, the experimentation time (in hours)
        "
        exit 0
}

while getopts c:hln:r:st: name; do
        case $name in
                c)
                        CLUSTER="$OPTARG"
                ;;
                h)
                        usage
                ;;
                l)
                        echo "No default cluster"
                        echo "Number of nodes: $NB_NODES"
                        echo "No subnet"
                        echo "Experimentation time: $HOURS"
                ;;
                n)
                        NB_NODES="$OPTARG"
                ;;
                r)
                        DATE="$OPTARG"
                ;;
#                s)
#                        SUBNET=true
#                ;;
                t)
                        HOURS="$OPTARG"
                ;;
                ?)
                        echo Option -$OPTARG not recognized!
                        exit 13
                ;;
        esac
done


SLEEPING=$(($HOURS * 3600))


if [ "default" = "$CLUSTER" ];then 
    echo "Reserve $NB_NODES nodes for $HOURS hours"
    if [ -z "$DATE" ];then
           ID=$(oarsub -t deploy "sleep $SLEEPING" -l {"type='kavlan'"}/vlan=1+nodes=$NB_NODES,walltime=$HOURS  -n "elastica" -t destructive | grep "OAR_JOB_ID" | cut -d '=' -f2) 
    else
       echo "Use the reservation date: $DATE"
       ID=$(oarsub -r "$DATE" -t deploy "sleep $SLEEPING" -l {"type='kavlan'"}/vlan=1+nodes=$NB_NODES,walltime=$HOURS  -n "elastica" -t destructive | grep "OAR_JOB_ID" | cut -d '=' -f2) 
    fi
else
    echo "Reserve $NB_NODES nodes on $CLUSTER for $HOURS hours"
    if [ -z "$DATE" ];then
           ID=$(oarsub -t deploy "sleep $SLEEPING" -l {"type='kavlan'"}/vlan=1+{"cluster='$CLUSTER'"}/nodes=$NB_NODES,walltime=$HOURS  -n "elastica" -t destructive | grep "OAR_JOB_ID" | cut -d '=' -f2) 
    
    else
           echo "Use the reservation date: $DATE"
           ID=$(oarsub -r "$DATE" -t deploy "sleep $SLEEPING" -l {"type='kavlan'"}/vlan=1+{"cluster='$CLUSTER'"}/nodes=$NB_NODES,walltime=$HOURS  -n "elastica" -t destructive | grep "OAR_JOB_ID" | cut -d '=' -f2) 
    fi
fi 

echo "Job (id: $ID) is waiting..."
PREV=$(oarstat -f -j $ID | grep scheduledStart | grep -v "no")
while [ -z "$PREV" ];do
        sleep $SLEEP
        PREV=$(oarstat -f -j $ID | grep scheduledStart | grep -v "no")
done
PREV=$(echo $PREV | sed 's:scheduledStart =::')
echo "Prevision time: $PREV"
until oarstat -s -j $ID | grep Running ; do
        echo "Job (id: $ID) is waiting..."
        sleep $SLEEP
done

#oarstat -f -j $ID | grep assigned_hostnames | awk '{print $3}' | tr '+' '\n' > $RESERVATION_NODES_FILE
echo "Submission complete"

