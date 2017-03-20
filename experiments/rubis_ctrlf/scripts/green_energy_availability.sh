
AVAILABLE_ENERGY_FILE=$1
SLEEP_TIME=$2
shift 
shift
TIERS=$@

sleep $SLEEP_TIME
for line in $(cat $AVAILABLE_ENERGY_FILE); do
	start=$(date +%s)
        value=$line 
        i=0
        for tier in $TIERS
        do
           /share/elasticity_manager/handle_energy.sh $tier energy $line &
         pids[$i]=$!
         i=`expr $i + 1`
        done
        for pid in ${pids[*]}
        do
           wait $pid
        done
        diff=`expr $(date +%s) - $start`
        remaining=`expr $SLEEP_TIME - $diff`
        if [ $remaining -gt 0 ]
        then 
	   sleep $remaining
        fi
done

# < $AVAILABLE_ENERGY_FILE

