
AVAILABLE_ENERGY_FILE=$1
SLEEP_TIME=$2

for line in $(cat $AVAILABLE_ENERGY_FILE); do
        sleep $SLEEP_TIME
	value=$line 
	/share/elasticity_manager/handle_energy.sh energy $line	
        done

# < $AVAILABLE_ENERGY_FILE

