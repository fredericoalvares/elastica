#!/bin/bash

# sert à traiter les evenement : POUR L'INSTANT ON NE S'OCCUPE QUE DU RESPONSE TIME
#seuils en secondes
rt_setpoint=1.00
threshold=0.20
zero=0.00
check_workload=0.50

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

# checking the workload increase.
file1='/share/elasticity_manager/count.txt'
echo "$workload" >> "$file1"
#echo "current workload is $workload"
value=$(wc -l "$file1")
nb_lines=${value%% *}
echo " no of line is $nb_lines"

if [ $nb_lines == 5 ]
then
       del=$(tail -n +2 "$file1")
       echo "$del"
       echo "$del" > "$file1"
       aa=$(cat "$file1")
       echo "$aa"

       fileItemString=$(cat "$file1" |tr "\n" " ")
       fileItemArray=($fileItemString)

       IFS=$'\n' sorted=($(sort -n <<<"${fileItemArray[*]}"))  # Sort the array
	echo "sorted array is ${sorted[*]}"
	# calculate median
	             index=`expr ${sorted[1]} + ${sorted[2]}`
	echo "index is $index"
	             median=`expr $index / 2`
	echo "median is $median"     
	            work_inc=$(bc -l <<<"scale=2; ($workload / $median)")
	echo "workload increase is $work_inc"
	
	# Adding VM
	currentTime=$(date +%s%N | cut -b1-13)

	if [ `bc -l <<< "$current_rt > $rt_setpoint"` -eq 1 ] && [ `bc -l <<< "$currentTime > $add_period"` -eq 1 ] && [ `bc -l <<< "$vm < $maxVM"` -eq 1 ] 
              then
                  echo "We are adding 1 VM"  #action line, add 1 VM
                  /root/action.sh out $src
		  coolingTime=`expr $currentTime + 400000`
                  vmNumber=`expr $vm + 1`
       
                  echo "VM number now : $vmNumber"
                  echo "$vmNumber" > "$instanceNumber"
                  echo "$coolingTime" > "$cold_period_add"
                  echo "Cooling period end : $coolingTime"


# Removing VM

	elif [ `bc -l <<< "$current_rt < $threshold"` -eq 1 ] && [ `bc -l <<< "$currentTime > $remove_period"` -eq 1 ] && [ `bc -l <<< "$minVM < $vm"` -eq 1 ] && [ `bc -l <<< "$work_inc < $check_workload"` -eq 1 ]
              
              then
             
                      echo "We are aremoving 1 VM"   #action line, remove 1 VM
                      /root/action.sh "in" $src
                      coolingTime=`expr $currentTime + 400000`
                      echo  "VM number previous : $vm"
                      vmNumber=`expr $vm - 1`
                      
                      echo "VM number now : $vmNumber"
                      echo "$vmNumber" > "$instanceNumber"
                      echo "$coolingTime" > "$cold_period_remove"
                      echo "Cooling period end : $coolingTime"

	 else 
         	echo "Do nothing !" 



	fi
fi
