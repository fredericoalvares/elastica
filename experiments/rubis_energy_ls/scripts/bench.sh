#!/bin/bash

#PATTERNS_WORKLOAD="IncreasingWorkload WorkloadPeak" #name pattern

PATTERNS_WORKLOAD="wikipedia"

#STRATEGIES="nothing horInfra_vertSoft onlyhorInfra onlyvertSoft"
#STRATEGIES="horInfra_vertSoft onlyhorInfra onlyvertSoft"
STRATEGIES="onlyvertSoft"
if ! [ -d /share ] || ! [ -f /root/adminrc ]
then
	echo "This script must be executed on the Cloud controller"	
        exit 1
fi


cd $PROJECT_PATH

source $PROJECT_PATH/common/util.sh


if ! [ -f $G5K_USER_PATH -a -f $G5K_PWD_PATH ]
then
    echo "Error: Username or password not stored!"
    exit 1
fi

#G5K_PWD=$(cat $G5K_PWD_PATH | base64 --decode)
G5K_USER=$(cat $G5K_USER_PATH)

PATH_RESULTS=$PROJECT_PATH/experiments/rubis_energy_ls/results

NAME_BENCH=bench_`date +%s`

PATH_RESULT_BENCH=$PATH_RESULTS/$NAME_BENCH

#NB_INSTANCES=2

#INJECTOR_NODES_FILE=$PROJECT_PATH/tmp/injectors.txt

if [ -e $PATH_RESULT_BENCH ]
then
	rm -rf $PATH_RESULT_BENCH
fi

mkdir $PATH_RESULT_BENCH

#exec &> $PATH_RESULT_BENCH/result.std 

NUMBER_APPLICATIONS=`expr $(wc -l $INJECTOR_NODES_FILE |cut -d ' ' -f1)`

name_tier=tier

#retrieve the name of the compute nodes
compute_nodes=$(nova host-list | grep compute | tr '|' ' ' | tr -s ' ' | cut -d ' ' -f 2)

nodes=
c=1
for n in $compute_nodes
do 
    nodes=$nodes" "$n 
    nodes_array[$c]=$n
    c=`expr $c + 1`
done

site=$(echo ${nodes_array[1]} | cut -d '.' -f2)
nodes_wo_site=$(echo $nodes | sed -e "s/\.$site\.grid5000\.fr//g" | sed -e 's/ /,/g')
echo "Compute nodes: $nodes"

delete(){
    check=0
    counter=0
    while [ $check -ne 1 ]
    do
        nova delete $1
        sleep 5
        deleted=$(nova list | grep $1)
        if [ -z "$deleted" ]
        then
           check=1
        else
           if [ $counter -gt 3 ]
           then
              echo "Error:  tried to delete VM 3 times with no success!"
              exit 0
           else
              nova reset-state $1
              counter=`expr $counter + 1`
           fi
        fi
    done
}

erase_plateforme () {
	for name_vm in `nova list | grep private | tr '|' ' ' | tr -s ' ' | cut -d ' ' -f 2`
	do
		delete $name_vm 
	done
	for name_vm in `nova list | grep ERROR | tr '|' ' ' | tr -s ' ' | cut -d ' ' -f 2`
	do
		delete $name_vm 
	done
	
    	for i in `seq 1 $NUMBER_APPLICATIONS`
        do 
            if [ -e $TIER_LIST_PATH/$name_tier$i ]
	    then
		rm -rf $TIER_LIST_PATH/$name_tier$i
	    fi
        done
	echo '#!/bin/bash' > /root/action.sh
	echo "echo \$0 \$1 \$2" >> /root/action.sh
	echo "source $PROJECT_PATH/common/util.sh" >> /root/action.sh
	chmod +x /root/action.sh	
	
}

init_plateforme () {
    for i in `seq 1 $NUMBER_APPLICATIONS`
    do
      echo "Launching DB on host "${nodes_array[$i]}
      $PROJECT_PATH/apicloud/new_vm.sh 5 db-rubis$i db dbtier$i ${nodes_array[$i]} #&
#      DB_IP_ADDRESS=`nova list | grep dbtier$i | tr "|" " " |tr -s " " | cut -d ' ' -f5 | cut -d "=" -f2`
      pids[`expr $i - 1`]=$! 
    done
    for i in `seq 1 $NUMBER_APPLICATIONS`
    do
       wait ${pids[`expr $i - 1`]}
    done
    for i in `seq 1 $NUMBER_APPLICATIONS`
    do
     # DB_IP_ADDRESS=`nova list | grep db-rubis$i | tr "|" " " |tr -s " " | cut -d ' ' -f8`
      # take private ip instead
      DB_IP_ADDRESS=`nova list | grep db-rubis$i | tr "|" " " |tr -s " " | cut -d ' ' -f7 | cut -d '=' -f2 | cut -d ',' -f1`
      echo $DB_IP_ADDRESS > $DB_INFO_FILE
      echo "Scaling $name_tier$i on host "${nodes_array[$i]}
      $PROJECT_PATH/apicloud/scale-iaas.sh out $name_tier$i ${nodes_array[$i]} #&
        
      echo "0" > "/share/elasticity_manager/cloud_state_"$name_tier$i".txt"
      echo "0" > "/share/elasticity_manager/tstamp_"$name_tier$i".txt"
      
      file_count='/share/elasticity_manager/count_'$name_tier$i'.txt' 
      echo "0" > $file_count
      echo "0" >> $file_count
      echo "0" >> $file_count
      echo "0" >> $file_count

      echo "0" > '/share/elasticity_manager/r0_'$name_tier$i'.txt'
      echo "0" > '/share/elasticity_manager/r1_'$name_tier$i'.txt'
      echo "0" > '/share/elasticity_manager/r2_'$name_tier$i'.txt'

      pids[`expr $i - 1`]=$! 
    done
    for i in `seq 1 $NUMBER_APPLICATIONS`
    do
       wait ${pids[`expr $i - 1`]} 
    done
}


reset_plateforme () {
	erase_plateforme
	init_plateforme	
}

ssh -o "StrictHostKeyChecking no" -i /tmp/id_rsa  $G5K_USER@frontend.lyon "mkdir -p ~/results"

#$PROJECT_PATH/apicloud/create_disk_images.sh LB
#$PROJECT_PATH/apicloud/create_disk_images.sh w
#$PROJECT_PATH/apicloud/create_disk_images.sh db

for pattern in $PATTERNS_WORKLOAD
do 
	for strategy in $STRATEGIES
	do
		#on nettoie les logs gatling
		rm -rf $PROJECT_PATH/gatling/results/*
		
		#on nettoie les log de ram/cpu
		echo "" > $DEFAULT_LOCAL_CONF_PATH/output-system.csv
		
		
		name_experiment="exp_"$pattern"_"$strategy
		path_experiment=$PATH_RESULT_BENCH/$name_experiment
		
		#on créé le répertoire de resultats de bench
		mkdir $path_experiment
		
		rm -f $TMP_FILE_LOG_CLOUD_STATE"*"
#		touch $TMP_FILE_LOG_CLOUD_STATE
	
		for i in `seq 1 $NUMBER_APPLICATIONS`
              	do
 		      touch $TMP_FILE_LOG_CLOUD_STATE"_"$name_tier$i
                done

		#on supprime la plateforme actuelle 
		erase_plateforme	
				
		#on réinitialise la plateforme : par defaut un seul worker
		init_plateforme
			
		unset http_proxy
		unset https_proxy
		

		
		
		#on logue l'etat du systeme avant l'action
#		echo "log_cloud_state b_\$1" >> /root/action.sh
		echo "$PROJECT_PATH/experiments/rubis_energy_ls/scripts/getCloudState.sh b_\$1 >> $TMP_FILE_LOG_CLOUD_STATE\"_\"\$2" >> /root/action.sh
#                for i in `seq 1 $NUMBER_APPLICATIONS`
#		do
                   #on spécifie la stratégie que lon veut utiliser
        	   echo "$PROJECT_PATH/apicloud/strategies/$strategy.sh \$1 \$2" >> /root/action.sh
#		done
		#on logue l'etat du systeme apres l'action
#		echo "log_cloud_state e_\$1" >> /root/action.sh
                echo "$PROJECT_PATH/experiments/rubis_energy_ls/scripts/getCloudState.sh e_\$1 >> $TMP_FILE_LOG_CLOUD_STATE\"_\"\$2" >> /root/action.sh
                tiers=
		for i in `seq 1 $NUMBER_APPLICATIONS`
		do
		#   ADRESS_IP_LB=`nova list | grep $name_tier$i"_VM_LB" | tr "|" " " |tr -s " " | cut -d ' ' -f5 | cut -d "=" -f2`
		   ADRESS_IP_LB=`nova list | grep $name_tier$i"_VM_LB" | tr "|" " " |tr -s " " | cut -d ' ' -f8`
		   while ! curl $ADRESS_IP_LB:$LB_PORT ; do echo "has done curl $ADRESS_IP_LB:$LB_PORT" ; sleep 1 ; done
		   lb_addresses[`expr $i - 1`]=$ADRESS_IP_LB
                   tiers=$tiers' '$name_tier$i
#		   export JAVA_OPTS="-DlbURL=http://$ADRESS_IP_LB:$LB_PORT"
                done

                logstash="logstash-1.4.2"
 		$DEFAULT_LOCAL_CONF_PATH/$logstash/bin/logstash agent -f $DEFAULT_LOCAL_CONF_PATH/indexer_logstash.conf > /tmp/stdout_logstash 2> /tmp/stderr_logstash &
                LOGSTASH_PID=$!

                #timestamp of the beginning of the experiments
                start_timestamp=$(date +%s)		

		#launch the green energy availability file reader
	       # $PROJECT_PATH/experiments/rubis_energy_ls/scripts/green_energy_availability.sh $PROJECT_PATH/experiments/rubis_energy_ls/scripts/green_energy_availability.txt 60 $tiers &

             #   GREEN_AVAILABILITY_PID=$! 

 	
                #launch experiment
		end=`expr $NUMBER_APPLICATIONS`
		for i in `seq 1 $end`
	        do
		     injector_node=$(sed -n $i'p' $INJECTOR_NODES_FILE)
		     cmd1="export JAVA_OPTS=\"-DlbURL=http://"${lb_addresses[`expr $i - 1`]}":"${LB_PORT}"\""
#		     cmd2="sh -c 'nohup ~/gatling/bin/gatling.sh -nr -s elastica.${pattern} > ~/run.log 2>&1 &'"
		     
                      if [ $i -lt $end ]
                      then
		          cmd2="sh -c 'nohup ~/gatling/bin/gatling.sh -nr -s elastica.${pattern} > ~/run.log 2>&1 &'"
                     else
		          cmd2="sh -c 'nohup ~/gatling/bin/gatling.sh -nr -s elastica.${pattern}'"
                    fi
                    echo "Launching injector "$injector_node 
		    ssh -o "StrictHostKeyChecking no" -i $PATH_KEYPAIR/id_rsa root@$injector_node "${cmd1} &&\
												    ${cmd2}" 
#                    pids_injectors[`expr $i - 1`]=$! 
 #   
		done
 #		for i in `seq 1 $NUMBER_APPLICATIONS`
  #  		do
   #                 echo "waiting injector "$i
    #   		    wait ${pids_injector[`expr $i - 1`]}
    #		done
#		echo "-DlbURL=http://"${lb_addresses[`expr $NUMBER_APPLICATIONS - 1`]}":"$LB_PORT

#		export JAVA_OPTS="-DlbURL=http://"${lb_addresses[`expr $NUMBER_APPLICATIONS - 1`]}":"$LB_PORT
#        	$PROJECT_PATH/gatling/bin/gatling.sh -nr -s elastica.$pattern

                #timestamp of the beginning of the end of the experiments
                end_timestamp=$(date +%s)		
	
                kill $GREEN_AVAILABILITY_PID
		kill $LOGSTASH_PID

		#on sauvegarde les donnée liées à létat de la plateforme
		cp ${TMP_FILE_LOG_CLOUD_STATE}"*" $path_experiment/
#state_plateforme.log
		
		#on sauvegarde les données liées à gatling (temps de réponse)	
	#	mv $PROJECT_PATH/gatling/results/* $path_experiment/
	
		#echo "Gathering result file from localhost"
		#ls -t $PROJECT_PATH/gatling/results/ | head -n 1 | xargs -I {} mv $PROJECT_PATH/gatling/results/{} $PROJECT_PATH/gatling/results/report
		#cp $PROJECT_PATH/gatling/results/report/simulation.log $GATHER_REPORTS_DIR

#		end=`$NB_INSTANCES - 1`
		for i in `seq 1 $end`
		do
		   injector_node=$(sed -n $i'p' $INJECTOR_NODES_FILE)
		   echo "Gathering result file from host: $injector_node"
#		   ssh -n -f root@$injector_node "sh -c 'ls -t ~/gatling/results/ | head -n 1 | xargs -I {} mv ${GATLING_REPORT_DIR}{} ${GATLING_REPORT_DIR}report'"
		   scp -o "StrictHostKeyChecking no" -i $PATH_KEYPAIR/id_rsa  -r root@$injector_node:~/gatling/results/* $path_experiment/
# ${GATHER_REPORTS_DIR}simulation-$i.log
		   ssh -o "StrictHostKeyChecking no" -i $PATH_KEYPAIR/id_rsa root@$injector_node "rm -r ~/gatling/results/*" 
		done

		for i in `seq 1 $NUMBER_APPLICATIONS`
		do
		   ADRESS_IP_LB=`nova list | grep $name_tier$i"_VM_LB" | tr "|" " " |tr -s " " | cut -d ' ' -f8`
                
        	   #on sauvegarde les données liées a nginx
		   scp -o "StrictHostKeyChecking no" -i $PATH_KEYPAIR/id_rsa ubuntu@$ADRESS_IP_LB:/root/access_nginx.log $path_experiment/access_nginx${i}.log
	        done
	       
       #         $PROJECT_PATH/gatling/bin/gatling.sh -ro $path_experiment/
	
		#on sauvegarde les données liées à la ram et au cpu
		mv $DEFAULT_LOCAL_CONF_PATH/output-system.csv $path_experiment/
		
		#on sauvegarde le scenario
		cp $PROJECT_PATH/gatling/user-files/simulations/elastica/$pattern.scala $path_experiment/
		
		#on sauvegarde le code du handler de l'elasticité manager
		cp $PROJECT_PATH/elasticity_manager/handle_event.sh $path_experiment/
	
	
		#retrieving energy log files
                echo "retrieving energy log files from"$nodes
#                $PROJECT_PATH/experiments/rubis_energy_ls/scripts/get_energy_log.sh $start_timestamp $end_timestamp $path_experiment $nodes



		curl -kn "https://api.grid5000.fr/stable/sites/$site/metrics/power/timeseries?resolution=1&only=$nodes_wo_site&from="$start_timestamp"&to="$end_timestamp > $path_experiment/energy_measurements.json
                		
		rm -f /root/action.sh
		echo "checking if action in progress"
		#on ne peut passer qu'à l'expé suivante si on on a pas d'action en cours
		while ! [ -z "`ps aux | grep /root/action.sh | grep -v grep`" ]
		do 
			echo -n "."
			sleep 1
		done
		
		echo "no more action in progress"
		
	done
done
if [ -d $PATH_RESULT_BENCH ]
then 
    TAR_PATH_RESULTS=$PATH_RESULTS/$NAME_BENCH'.tar.gz'
    tar cvf $TAR_PATH_RESULTS -C $PATH_RESULTS $NAME_BENCH
    scp -o "StrictHostKeyChecking no" -i /tmp/id_rsa -r $TAR_PATH_RESULTS $G5K_USER@frontend.lyon:~/results/
fi
