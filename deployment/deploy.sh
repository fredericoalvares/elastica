#!/bin/sh


if [ "`env|grep PROJECT_PATH`" = "" ]
then
        echo "PROJECT_PATH is not defined, using ~/elastica"
        export PROJECT_PATH=~/elastica
fi

source $PROJECT_PATH/common/util.sh

if [ "`env | grep "OAR_NODE_FILE"`" = "" ]
then
    if [ $# -ne 1 ]
    then
        echo "You are not connected to a JOB. Please connect to a JOB or provide a JOB ID!"
        echo $0 job_id
        exit 1
    else 
        JOB_ID=$1
        oarstat -f -j $JOB_ID | grep assigned_hostnames | awk '{print $3}' | tr '+' '\n' > $RESERVATION_NODES_FILE
    fi        
else 
    JOB_ID=$OAR_JOBID
    RESERVATION_NODES_FILE=$OAR_NODEFILE
fi


if [ ! -f "$RESERVATION_NODES_FILE" ]
then
    echo "File $RESERVATION_NODES_FILE not found, you should execute the \$ELASTICA_HOME/setup.sh script"
    exit 1
fi

echo "Deploying nodes: " $(cat $RESERVATION_NODES_FILE)

extra_injectors=`expr $NUMBER_APPLICATIONS - 1`

#kadeploy3 -e ubuntu-x64-1204 -f $RESERVATION_NODES_FILE --vlan `kavlan -j $JOB_ID -V` -k
#kavlan -j $JOB_ID -l | tail -n +2 > $KVLAN_NODES_FILE
kavlan -j $JOB_ID -l | sed '1,'$extra_injectors'd' > $KVLAN_NODES_FILE



cd $OPENSTACK_CAMPAIGN_HOME 

ruby bin/openstackg5k -m educ -i $KVLAN_NODES_FILE

cd -

echo "Openstack deployment done! Ready to install elastica."


