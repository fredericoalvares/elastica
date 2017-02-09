#!/bin/bash
	
temp=$1
src=$2
metric=$3
resTime=$4 # current response time.
workInc=$5  # current workload increase.
maxVM=6
minVM=1
addVmNumber=1
redrt=.50 # it should be "target responseTime/2"
decWork=1 # ration of (currentRequest/MedianRequest)

cold_period_add='cold_period_add.txt'
add_period=$(cat "$cold_period_add")
cold_period_remove='cold_period_remove.txt'
remove_period=$(cat "$cold_period_remove")
instanceNumber='instance_number.txt'
vm=$(cat "$instanceNumber")
#oldR0=`cat $recZeroFile`


# initiate instanceNumber=1, cold_period_add=0, cold_period_remove=0. (in the file) 
# Adding VM
if [ "$metric" = "add" ]
then
echo "add VM : $temp $metric $resTime $workInc"
currentTime=$temp
#echo "Current time : $currentTime"

if [ `bc -l <<< "$currentTime > $add_period"` -eq 1 ] && [ `bc -l <<< "$vm < $maxVM"` -eq 1 ]

then
        echo "We are adding 1 VM"  #action line, add 1 VM
        /root/action.sh out $src
	coolingTime=`expr $currentTime + 300`
        echo "VM number previous : $vm"
        vmNumber=`expr $vm + 1`
       
        echo "VM number now : $vmNumber"
        echo "$vmNumber" > "$instanceNumber"
        echo "$coolingTime" > "$cold_period_add"
        echo "Cooling period end : $coolingTime"

else 
         echo "Adding VM already on the process" 

fi 
fi


# Removing VM

if [ "$metric" = "remove" ]
then
echo "remove VM : $temp $resTime $workInc"
currentTime=$temp
echo "Current time : $currentTime"

if [ `bc -l <<< "$currentTime > $remove_period"` -eq 1 ] && [ `bc -l <<< "$redrt > $resTime"` -eq 1 ] && [ `bc -l <<< "$workInc < $decWork"` -eq 1 ] && [ `bc -l <<< "$minVM < $vm"` -eq 1 ]
then
             
             echo "We are aremoving 1 VM"   #action line, remove 1 VM
             /root/action.sh "in" $src
             coolingTime=`expr $currentTime + 300`


             echo -e "VM number previous : $vm"
             vmNumber=`expr $vm - 1`
       
             echo "VM number now : $vmNumber"
             echo "$vmNumber" > "$instanceNumber"
            echo "$coolingTime" > "$cold_period_remove"
            echo "Cooling period end : $coolingTime"

else 
         echo "Removing VM is on process" 

fi 
fi














































