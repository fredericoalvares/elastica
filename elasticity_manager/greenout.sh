rt_setpoint=1.00
pole=0.5
u_pole=0.5  #u_pole= 1 - pole.

cloud_state='/share/elasticity_manager/cloud_state.txt'
dimmer_file=$(cat "$cloud_state")

intermediate_dimmer='/share/elasticity_manager/int_dimmer.txt'
int_dimmer=$(cat "$intermediate_dimmer")


tracking_dimmer='/share/elasticity_manager/tracking.txt'


t='/share/elasticity_manager/tstamp.txt'
time_file=$(cat "$t")

distance=3000.00
distance1=12000.00

timestamp=$1
metric=$2
val=$3


if [ "$metric" = "energy" ]
then
  echo "handle_event energy : $timestamp $metric $val"
               
               current_time=$timestamp
               dimmer=$val

                sens=$dimmer
               /root/action.sh $sens

               next_time=`expr $current_time + 15000` #60 second slot for green energy, small exp can be 30 second
               echo "$next_time"
               echo "$next_time" > "$t"
               echo "$dimmer" > "$cloud_state"
               echo "$dimmer" > "$intermediate_dimmer"
               echo "$dimmer" >> "$tracking_dimmer"

fi 



if [ "$metric" = "rt.p95" ]
then
 echo "handle_event Rt : $timestamp $metric $val"
 IFS=':' read -a rt_data <<< "$val"

       current_rt=${rt_data[0]}
       rt_time=$timestamp
       time_diff=`expr $time_file - $rt_time`

       if [ `bc -l <<< "$time_diff > $distance"` -eq 1 ] && [ `bc -l <<< "$time_diff < $distance1"` -eq 1 ]
         then
      # calculate alpha, which need to be estimated. We are using bare estimation. alpha(t+1)=Rt(t)/dim(t).
       alpha=$(bc -l <<<"scale=5; ($current_rt / $int_dimmer)")
       echo "alpha is $alpha"
       gain=$(bc -l <<<"scale=5; ($u_pole / $alpha)")
       echo "gain is $gain"
       error=$(bc -l <<<"scale=5; ($rt_setpoint - $current_rt)")
       echo "current error is $error"
       change=$(bc -l <<<"scale=5; ($gain * $error)")
       echo "changed param is $change"
       dimmer_update=$(bc -l <<<"scale=5; ($int_dimmer + $change)") 
       echo "Updated dimmer value is $dimmer_update"

           if [ `bc -l <<< "$dimmer_update < $dimmer_file"` -eq 1 ]
            then
                sens=$dimmer_update
                /root/action.sh $sens
                echo "dimmer value $dimmer_update is changed in worker"
                echo "$dimmer_update" > "$intermediate_dimmer"
                echo "$dimmer_update" >> "$tracking_dimmer"
                
            else
                echo "$dimmer_file" > "$intermediate_dimmer"
                echo "$dimmer_file" >> "$tracking_dimmer"
           fi


fi

fi

