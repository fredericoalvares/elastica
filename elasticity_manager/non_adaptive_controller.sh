#!/bin/bash

# sert à traiter les evenement : POUR L'INSTANT ON NE S'OCCUPE QUE DU RESPONSE TIME
#seuils en secondes
rt_setpoint=1.00
threshold=0.20
zero=0.00

maxVM=6
minVM=1
addVmNumber=1

timestamp=$1
src=$2
metric=$3
val=$4
#file='/share/elasticity_manager/array.txt'
echo "handle_event debut : $timestamp $metric $val"

IFS=':' read -a rt_data <<< "$val"

current_rt=${rt_data[0]} # divide current_rt/1000
workload=${rt_data[1]}

cold_period_add='/share/elasticity_manager/cold_period_add.txt'
add_period=$(cat "$cold_period_add")
cold_period_remove='/share/elasticity_manager/cold_period_remove.txt'
remove_period=$(cat "$cold_period_remove")
instanceNumber='/share/elasticity_manager/instance_number.txt'
vm=$(cat "$instanceNumber")

# Adding VM
currentTime=$(date +%s)

if [ `bc -l <<< "$current_rt > $rt_setpoint"` -eq 1 ] && [ `bc -l <<< "$currentTime > $add_period"` -eq 1 ] && [ `bc -l <<< "$vm < $maxVM"` -eq 1 ]
              then
                  echo "We are adding 1 VM"  #action line, add 1 VM
                  /root/action.sh out $src 
		  coolingTime=`expr $currentTime + 300000`
                  echo "VM number previous : $vm"
                  vmNumber=`expr $vm + 1`
       
                  echo "VM number now : $vmNumber"
                  echo "$vmNumber" > "$instanceNumber"
                  echo "$coolingTime" > "$cold_period_add"
                  echo "Cooling period end : $coolingTime"


# Removing VM

elif [ `bc -l <<< "$current_rt < $threshold"` -eq 1 ] && [ `bc -l <<< "$currentTime > $remove_period"` -eq 1 ] && [ `bc -l <<< "$minVM < $vm"` -eq 1 ]
              
              then
             
                      echo "We are aremoving 1 VM"   #action line, remove 1 VM
                      /root/action.sh "in" $src
                      coolingTime=`expr $currentTime + 300000`
                      echo  "VM number previous : $vm"
                      vmNumber=`expr $vm - 1`
                      
                      echo "VM number now : $vmNumber"
                      echo "$vmNumber" > "$instanceNumber"
                      echo "$coolingTime" > "$cold_period_remove"
                      echo "Cooling period end : $coolingTime"

else 
         echo "Do nothing !" 



fi

















