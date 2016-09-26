
AVAILABLE_ENERGY_FILE=$1
SLEEP_TIME=$2
shift 
shift
TIERS=$@

for line in $(cat $AVAILABLE_ENERGY_FILE); do
        sleep $SLEEP_TIME
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

done

# < $AVAILABLE_ENERGY_FILE

