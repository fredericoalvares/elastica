thr_e1=5.0
thr_e2=15.0
response_time=1.00
downgrade=1

rt_setpoint=1.00
threshold=0.50
zero=0.00
distance=10000.00
distance1=50000.00

timestamp=$1
metric=$2
val=$3

cloud_state='/share/elasticity_manager/cloud_state.txt'
old_state=$(cat "$cloud_state")
t='/share/elasticity_manager/tstamp.txt'
time_file=$(cat "$t")

# The files where the no of request associated with modes will be stored
recZeroFile='/share/elasticity_manager/r0.txt'
recOneFile='/share/elasticity_manager/r1.txt'
recTwoFile='/share/elasticity_manager/r2.txt'
greenfile='/share/elasticity_manager/greenValue.txt'
# SLA target for recommendation, depending what we put here!
rec1=50
rec2=30

#Read the file
oldR0=$(cat "$recZeroFile")
oldR1=$(cat "$recOneFile")
oldR2=$(cat "$recTwoFile")
green=$(cat "$greenfile")

               if [ "$metric" = "energy"  ]
                  then
                     echo "handle_event energy : $timestamp $metric $val"
                     green_curr=$val
                     echo "$green_curr" > "$greenfile"
               fi
 
if [ "$metric" = "modes" ]
then
  echo "handle_event energy : $timestamp $metric $val"
   IFS=':' read -a counter <<< "$val"

  echo "No mode: ${counter[0]} | Mode 0: ${counter[1]} | Mode 1: ${counter[2]} | Mode 2: ${counter[3]}"

a=${counter[1]}
b=${counter[2]}
c=${counter[3]}
current_time=$timestamp
next_time=`expr $current_time + 60000` #60 second slot for green energy, small exp can be 30 second
echo "$next_time"
echo "$next_time" > "$t"

if [ -f "$recZeroFile" ] && [ -f "$recOneFile" ] && [ -f "$recTwoFile" ]
then
x=`expr $a + $oldR0`
y=`expr $b + $oldR1`
z=`expr $c + $oldR2`
   echo "$x" > "$recZeroFile"
   echo "$y" > "$recOneFile"
   echo "$z" > "$recTwoFile"
fi

per1=$(bc -l <<<"scale=2; $y*100/($x+$y+$z)")
per2=$(bc -l <<<"scale=2; $z*100/($x+$y+$z)")
temp1=$(bc -l <<<"scale=2; $rec1 - $per1")
temp2=$(bc -l <<<"scale=2; $rec2 - $per2")

echo "REC1 is $per1"
echo "REC2 is $per2"
echo "REC1 dist is $temp1"
echo "REC2 dist is $temp2"
#just to check if the values are ok or not!!!!!!

if [ `bc -l <<< "$rec1 < $per1"` -eq 1 ] && [ `bc -l <<<"$rec2 > $per2"` -eq 1 ]
      then
         sens="2"
   elif [ `bc -l <<< "$rec1 > $per1"` -eq 1 ] && [ `bc -l <<<"$rec2 < $per2"` -eq 1 ]
   then
         sens="1"
   elif [ `bc -l <<< "$rec1 > $per1"` -eq 1 ] && [ `bc -l <<<"$rec2 > $per2"` -eq 1 ]
   then
       if [ `bc -l <<< "$temp1 < $temp2"` -eq 1 ]
       then
            sens="2"
       else
            sens="1"
        fi
    elif [ `bc -l <<< "$thr_e2 < $green"` -eq 1 ]
    then
         sens="2"
         echo "Good amount of energy, why not mode 2! "
    elif [ `bc -l <<< "$thr_e1 < $green"` -eq 1 ] && [ `bc -l <<<"$thr_e2 > $green"` -eq 1 ]
    then
         sens="1"
         echo "Moderate amount of energy, why not mode 1! "

  else
       sens="0"
       echo "Sorry, no energy! "

fi
    /root/action.sh $sens
     echo "$sens" > "$cloud_state"
echo "Perc rec1 $per1 % and Perc rec2 $per2 %, distance for rec1 $temp1% and distance for rec2 is $temp2% " >> /share/elasticity_manager/SLA.txt

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
                            /root/action.sh $x
                         echo "$x" > "$cloud_state"
                         echo "Downgrading User experience due to high response time, current mode $x"
                   fi
          fi
fi    
