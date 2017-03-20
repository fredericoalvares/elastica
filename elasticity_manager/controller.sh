#!/bin/bash

timestamp=$1
src=$2
metric=$3
val=$4

echo "handle_event debut : $timestamp $metric $val"

IFS=':' read -a rt_data <<< "$val"

current_rt=${rt_data[0]} # divide current_rt/1000
workload=${rt_data[1]}

echo "$timestamp $workload $current_rt" >> /tmp/workload_rt.txt

MANAGER_PATH='/share/elasticity_manager'
CTRLF_STATE_LOG='/tmp/ctrlf_state.log'

cold_period_add_file=$MANAGER_PATH'/cold_period_add.txt'
add_period=$(cat "$cold_period_add_file")
cold_period_remove_file=$MANAGER_PATH'/cold_period_remove.txt'
remove_period=$(cat "$cold_period_remove_file")

REMOVE_COOLING_PERIOD=200000
ADD_COOLING_PERIOD=200000




threshold1="200.0"
threshold2="-3.5"

coef=5000.0

current_time=$(date +%s%N | cut -b1-13)



st=$(tail -1 $CTRLF_STATE_LOG)

pworkload=$(echo $st | tr -s ' ' | cut -d ' ' -f 2)
stserver1=$(echo $st | tr -s ' ' | cut -d ' ' -f 3)
stserver2=$(echo $st | tr -s ' ' | cut -d ' ' -f 4)

#c1=$(expr $stserver1 \* 10)
#c2=$(expr $stserver2 \* 10)

pr=$(echo "$stserver1+$stserver2" | bc)

q=(2.0 1.0 2.0 1.5 1.5 1.0)
r=(1.0 2.0 2.0 3.0 3.0 4.0)

s1=(2.0 1.0 2.0 1.0 2.0 1.0)
s2=(0.0 0.0 2.0 2.0 1.0 1.0)

rmin=40.0
qmax=0.0


#echo ${q[*]}
#echo ${r[@]}

confs=

for i in $(seq 0 5) 
do
   w=$(echo "(${r[$i]}*$coef)-$workload" | bc)
   if (( $(bc <<< "$w > $threshold1") ))
   then
        confs=$confs" "$i
	if (( $(bc <<< "${q[$i]} >= $qmax") ))
	then
	   qmax=${q[$i]}
        fi
   fi
done
#echo $qmax
echo "Possible configurations: $confs"

confs2=
for i in $confs
do
    if (( $(bc <<< "${q[$i]} >= $qmax") ))
    then
        confs2=$confs2" "$i
    fi
done

#echo $confs2

for i in $confs2
do
	if (( $(bc <<< "(${s1[$i]}+${s2[$i]}) < $rmin") )) 
    then
	 rmin=(${s1[$i]}+${s2[$i]})
	 conf=$i
    fi
done

echo "Best configuration: $conf"

#
#

if [ "x$conf" = "x" ]; then
   echo "No solution found! Do nothing."
else
   if (( $(bc <<< "$pr != $rmin") )) 
   then
     if [ `bc -l <<< "$stserver2==0.0 && ${s2[$conf]}>0.0"` -eq 1 ]; then
	#if [ `bc -l <<< "$currenti_time > $add_period"` -eq 1 ]; then
	     echo "adding ..."

	     $PROJECT_PATH/apicloud/scale-iaas-lamp2.sh out $src

	#     cooling_time=`expr $current_time + $ADD_COOLING_PERIOD`
        #     echo "$cooling_time" > "$cold_period_add_file" 
	     echo "$timestamp $workload ${s1[$conf]} ${s2[$conf]}" >> $CTRLF_STATE_LOG
	#else
	#     echo "In add cold period! "
	#fi 
     elif  [ `bc -l <<< "$stserver2>0.0 && ${s2[$conf]}==0.0"` -eq 1 ]; then
	#if [ `bc -l <<< "$currenti_time > $remove_period"` -eq 1 ]; then
	     echo "removing ..."
             $PROJECT_PATH/apicloud/scale-iaas-lamp2.sh "in" $src
	#     cooling_time=`expr $current_time + $REMOVE_COOLING_PERIOD`
        #     echo "$cooling_time" > "$cold_period_remove_file" 
	     echo "$timestamp $workload ${s1[$conf]} ${s2[$conf]}" >> $CTRLF_STATE_LOG    
	#else
	#     echo "In removing cold period"
	#fi
     else 
     	echo "changing mode..."
        mode=$(echo "${s1[$conf]}/1" | bc)
	if [ $mode -eq 1 ]; then 
           mode=0
        fi  
        $PROJECT_PATH/apicloud/scale-saas2.sh $mode $src 1
        mode=$(echo "${s2[$conf]}/1" | bc)         
	if [ $mode -eq 1 ]; then 
           mode=0
        fi
        $PROJECT_PATH/apicloud/scale-saas2.sh $mode $src 2

	echo "$timestamp $workload ${s1[$conf]} ${s2[$conf]}" >> $CTRLF_STATE_LOG 
     fi
   else
     echo "Same configuration! Do nothing"  
   fi
fi
