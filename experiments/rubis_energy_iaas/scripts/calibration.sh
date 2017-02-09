#!/bin/bash

#PATTERNS_WORKLOAD="IncreasingWorkload WorkloadPeak" #name pattern

PATTERNS_WORKLOAD="Calibration"

#STRATEGIES="nothing horInfra_vertSoft onlyhorInfra onlyvertSoft"
#STRATEGIES="horInfra_vertSoft onlyhorInfra onlyvertSoft"
STRATEGIES="nothing"
STRATEGIES="2"
if ! [ -d /share ] || ! [ -f /root/openrc ]
then
	echo "doit etre execute sur le cloud controler"
	exit 1
fi


cd $PROJECT_PATH

source $PROJECT_PATH/common/util.sh





PATH_RESULTS=$PROJECT_PATH/experiments/rubis_energy/results

NAME_BENCH=bench_`date +%s`

PATH_RESULT_BENCH=$PATH_RESULTS/$NAME_BENCH

if [ -e $PATH_RESULT_BENCH ]
then
	rm -rf $PATH_RESULT_BENCH
fi

mkdir $PATH_RESULT_BENCH

name_tier=tier




erase_plateforme () {
	for name_vm in `nova list | grep novanetwork | tr '|' ' ' | tr -s ' ' | cut -d ' ' -f 3`
	do
		nova delete $name_vm 
	done
        
        nova image-delete WorkerImage
        
	if [ -e $TIER_LIST_PATH/$name_tier ]
	then
		rm -rf $TIER_LIST_PATH/$name_tier
	fi
	echo '#!/bin/bash' > /root/action.sh
	echo "echo \$0 \$1" >> /root/action.sh
	echo "source $PROJECT_PATH/common/util.sh" >> /root/action.sh
	chmod +x /root/action.sh	
	
}

init_plateforme () {
    $PROJECT_PATH/apicloud/new_vm.sh 2 db-rubis db dbtier
    DB_IP_ADDRESS=`nova list | grep db | tr "|" " " |tr -s " " | cut -d ' ' -f5 | cut -d "=" -f2`
    echo $DB_IP_ADDRESS > $DB_INFO_FILE

    if [ $1 -eq 1 ]
    then
      $PROJECT_PATH/apicloud/new_vm.sh 2 wrubis w $name_tier
    else
      for i in `seq 1 $1`
      do
         $PROJECT_PATH/apicloud/scale-iaas.sh out $name_tier
      done
    fi
}


reset_plateforme () {
	erase_plateforme
	init_plateforme	
}

ssh $G5K_USER@frontend "mkdir -p ~/results"

for pattern in $PATTERNS_WORKLOAD
do 
	for strategy in $STRATEGIES
	do
		#on nettoie les logs gatling
		rm -rf $PROJECT_PATH/gatling/results/*
		
		#on nettoie les log de ram/cpu
		echo "" > $DEFAULT_LOCAL_CONF_PATH/output-system.csv
		
		
		name_experiment="exp_"$pattern"_VM"$strategy
		path_experiment=$PATH_RESULT_BENCH/$name_experiment
		
		#on créé le répertoire de resultats de bench
		mkdir $path_experiment
		
		rm -f $TMP_FILE_LOG_CLOUD_STATE
		touch $TMP_FILE_LOG_CLOUD_STATE
	
                #retrieve the name of the compute nodes
                compute_nodes=$(nova host-list | grep compute | tr '|' ' ' | tr -s ' ' | cut -d ' ' -f 2)

                nodes=
		for n in $compute_nodes
                do 
                    nodes=$nodes" "$(echo $n | sed -n 's/^\(.*\)\-kavlan.*$/\1/p')
                done

	
		#on supprime la plateforme actuelle 
		erase_plateforme	
				
		#on réinitialise la plateforme : par defaut un seul worker
		init_plateforme $strategy
			
		
		unset http_proxy
		unset https_proxy
		
	        if [ $strategy -eq 1 ]
                then	
		   ADRESS_IP_LB=`nova list | grep wrubis | tr "|" " " |tr -s " " | cut -d ' ' -f5 | cut -d "=" -f2`
		else
		   ADRESS_IP_LB=`nova list | grep LB | tr "|" " " |tr -s " " | cut -d ' ' -f5 | cut -d "=" -f2`
                fi

                export JAVA_OPTS="-DlbURL=http://$ADRESS_IP_LB:$LB_PORT"
		while ! curl $ADRESS_IP_LB:$LB_PORT ; do echo "has done curl $ADRESS_IP_LB:$LB_PORT" ; sleep 1 ; done
		
		
#		if [ "$strategy" != "nothing" ]
#		then
			#on logue l'etat du systeme avant l'action
			echo "log_cloud_state b_\$1" >> /root/action.sh
			#on spécifie la stratégie que l'on veut utiliser
			echo "$PROJECT_PATH/apicloud/strategies/nothing.sh \$1 $name_tier" >> /root/action.sh
			#on logue l'etat du systeme apres l'action
			echo "log_cloud_state e_\$1" >> /root/action.sh
#		fi
	
                #timestamp of the beginning of the experiments
                start_timestamp=$(date +%s)		
		
                #on lance l'expérience
		$PROJECT_PATH/gatling/bin/gatling.sh -s elastica.$pattern

                #timestamp of the beginning of the end of the experiments
                end_timestamp=$(date +%s)		
	
		#on sauvegarde les donnée liées à l'état de la plateforme
		cp $TMP_FILE_LOG_CLOUD_STATE $path_experiment/state_plateforme.log
		
		#on sauvegarde les données liées à gatling (temps de réponse)	
		mv $PROJECT_PATH/gatling/results/* $path_experiment/
		
		#on sauvegarde les données liées a nginx
		scp -o "StrictHostKeyChecking no" -i $PATH_KEYPAIR/id_rsa ubuntu@$ADRESS_IP_LB:/root/access_nginx.log $path_experiment/
		
		#on sauvegarde les données liées à la ram et au cpu
		mv $DEFAULT_LOCAL_CONF_PATH/output-system.csv $path_experiment/
		
		#on sauvegarde le scenario
		cp $PROJECT_PATH/gatling/user-files/simulations/elastica/$pattern.scala $path_experiment/
		
		#on sauvegarde le code du handler de l'elasticité manager
		cp $PROJECT_PATH/elasticity_manager/handle_event.sh $path_experiment/
	
	
		#retrieving energy log files
                echo "retrieving energy log files from"$nodes
                $PROJECT_PATH/experiments/rubis_energy/scripts/get_energy_log.sh $start_timestamp $end_timestamp $path_experiment $nodes

		
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
    scp -o "StrictHostKeyChecking no" -r $PATH_RESULT_BENCH $G5K_USER@frontend:~/results/
fi
