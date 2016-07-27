#!/bin/bash

# sert à traiter les evenement : POUR L'INSTANT ON NE S'OCCUPE QUE DU RESPONSE TIME
#seuils en secondes
rt_setpoint=1.00
threshold=0.50
zero=0.00

timestamp=$1
metric=$2
val=$3
file='/share/elasticity_manager/array.txt'
echo "handle_event debut : $timestamp $metric $val"

if [ "$metric" = "rt.p95" ]
then
       IFS=':' read -a rt_data <<< "$val"

       current_rt=${rt_data[0]}
       workload=${rt_data[1]}

# send workload to file and delete first line
file1='/share/elasticity_manager/count.txt'
echo "$workload" >> "$file1"
echo "current workload is $workload"
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
             relative=$(bc -l <<<"scale=2; ($current_rt / $rt_setpoint)")
echo "relative is $relative"
     
            work_inc=$(bc -l <<<"scale=2; ($workload / $median)")
echo "workload increase is $work_inc"
            stability=$(bc -l <<<"scale=2; ($relative * $work_inc)")
echo "stability is $stability"
            func=$(bc -l <<<"scale=2; ($rt_setpoint - $stability)") # Here it should not be rt, rather should be 1,as rt=1, so i put it, otherwise its irrespective to Rt
       echo "value of f(t) is $func"

           if [ `bc -l <<<"$threshold < $func"` -eq 1 ]
                then
                   sens="2"
                   echo "Selecting mode $sens because Response time is super low!"
             elif [ `bc -l <<<"$zero > $func"` -eq 1 ]
                then
                   sens="0"
                   echo "Selecting mode $sens because Response time is high!"
             else
                   sens="1"
                   echo "Selecting mode $sens because Response time is in good region"
          fi
             /root/action.sh $sens
    fi
fi
#elif [ "$metric" = "modes" ]
#then
#  IFS=':' read -a counter <<< "$val"

#  echo "No mode: ${counter[0]} | Mode 0: ${counter[1]} | Mode 1: ${counter[2]} | Mode 2: ${counter[3]}"
  ### HERE YOU SHOULD PUT YOUR CONDITIONS/CONSTRAINTS BASED ON THE SLA
### AND CALL /root/action.sh BY PASSING AS ARGUMENT THE ELASTICITY LEVEL
 
#fi




#on met un temps de calme égal au tempde fenetre de monitoring
#sleep 30
