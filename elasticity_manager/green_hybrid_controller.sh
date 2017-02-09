
threshold_energy1=5.0
threshold_energy2=15.0
response_time=1.00
downgrade=1

rt_setpoint=1.00
threshold=0.50
zero=0.00
distance=10000.00
distance1=50000.00

timestamp=$1
src=$2
metric=$3
val=$4

cloud_state="/share/elasticity_manager/cloud_state_"$src".txt"
old_state=$(cat "$cloud_state")
t='/share/elasticity_manager/tstamp_'$src'.txt'
time_file=$(cat "$t")

if [ "$metric" = "energy" ]
then
  echo "handle_event energy : $timestamp $metric $val"
current_time=$timestamp
next_time=`expr $current_time + 60000` #60 second slot for green energy, small exp can be 30 second
echo "$next_time"
echo "$next_time" > "$t"

  if [ `bc -l <<<"$threshold_energy1 > $val"` -eq 1 ]
  then
        sens="0"
  elif [ `bc -l <<<"$threshold_energy2 < $val"` -eq 1 ]
  then
        sens="2"
  else
        sens="1"
  fi
  /root/action.sh $sens $src 
  echo "$sens" > "$cloud_state"

fi

if [ "$metric" = "rt.p95" ]
then
 echo "handle_event Rt : $timestamp $metric $val"
 IFS=':' read -a rt_data <<< "$val"

       current_rt=${rt_data[0]}
       workload=${rt_data[1]}
       rt_time=$timestamp
       time_diff=`expr $time_file - $rt_time`
       echo "$time_diff"
      
#it should be slot/2, meaning if rt slot is 20 sec each, then distance should be 10 sec, if rt slot 10 sec, dist is 5 sec
# send workload to file and delete first line
file1='/share/elasticity_manager/count_'$src'.txt'
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
#echo "sorted array is ${sorted[*]}"
# calculate median
             index=`expr ${sorted[1]} + ${sorted[2]}`
#echo "index is $index"
             median=`expr $index / 2`
#echo "median is $median"
             relative=$(bc -l <<<"scale=2; ($current_rt / $rt_setpoint)")
#echo "relative is $relative"

            work_inc=$(bc -l <<<"scale=2; ($workload / $median)")
echo "workload increase is $work_inc"
            stability=$(bc -l <<<"scale=2; ($relative * $work_inc)")
echo "stability is $stability"
            func=$(bc -l <<<"scale=2; ($rt_setpoint - $stability)") # Here it should not be rt, rather should be 1,as rt=1, so i put it, otherwise its irrespective to Rt
       echo "value of f(t) is $func"

  
                  if [ `bc -l <<< "$zero > $func"` -eq 1 ] && [ "$old_state" -ne 0 ] && [ `bc -l <<< "$time_diff > $distance"` -eq 1 ] && [ `bc -l <<< "$time_diff < $distance1"` -eq 1 ]
                     then
                         x=`expr $old_state - $downgrade`
                            /root/action.sh $x $src
                         echo "$x" > "$cloud_state"
                         echo "Downgrading User experience due to high response time, current mode $x"
                         
                         currentTime=$(date +%s)
                         /share/elasticity_manager/iaas_controller.sh $currentTime $src add $current_rt $work_inc
                         echo "Adding VM request send to iaaS Controller"
                         
                         
                   elif  [ `bc -l <<< "$zero < $func"` -eq 1 ] && [ "$old_state" -ne 0 ] && [ `bc -l <<< "$time_diff > $distance"` -eq 1 ] && [ `bc -l <<< "$time_diff < $distance1"` -eq 1 ]      
                      
                        currentTime=$(date +%s)
                         /share/elasticity_manager/iaas_controller.sh $currentTime $src remove $current_rt $work_inc
                         echo "Removing VM request send to iaaS Controller"
                         
                  else
                  
                         echo "No request send to iaaS Controller"
                   
                   
                   fi
          fi
fi    
