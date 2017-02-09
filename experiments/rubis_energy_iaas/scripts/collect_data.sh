#!/bin/bash


usage="$0 <absolute_path_result_bench>"
if [ $# -ne 1 ]
then
	echo $usage
	exit 1
fi

RESULT_BENCH=$1

cd $RESULT_BENCH

for exp in `ls | grep exp`
do
	if ! [ -d $exp ]
	then
		continue
	fi
	cd $RESULT_BENCH/$exp
	
	log_state_platform=state_plateforme.log
	
	repertoire_gatling=`ls -d */ | grep -E "\-[0-9]+"`
	
	log_gatling=$repertoire_gatling/simulation.log
	
	nb_vm=3
	level_appli=10000000
	cat $log_gatling | grep REQUEST | tr "\t" " " |tr -s " " | cut -d ' ' -f 3,6,8-9 | sed 's/-/ ID/' | cut -d ' ' -f 2- | sed 's/^\(ID[0-9]*\) \([0-9]*\) \([0-9]*\) \(..\)$/\2 \1ID \4 D:\3 \1ID \4 F/' | tr ':' '\n' | sort -n > /tmp/tmp
	cd $PROJECT_PATH/experiments/rubis_energy/scripts/transform_log
	make
	java TransformLog "/tmp/tmp" "$RESULT_BENCH/$exp/$log_state_platform" "$nb_vm" "$level_appli" | tee $RESULT_BENCH/$exp/logs.dat
	
	cd $RESULT_BENCH/$exp
	$PROJECT_PATH/experiments/rubis_energy/scripts/draw_curves.sh $RESULT_BENCH/$exp
	cd $RESULT_BENCH
done
















#	date_depart_seconde=""
#	cpt_entrant=0
#	cpt_sortant=0
#	sum_rt=0
#	cpt_rt=0
	
#	id_line_state_log=1
	
#	file_sauvegarde_tmp=/tmp/sauvegarde_tmp
#	rm -f $file_sauvegarde_tmp
	
	#cat $log_state_platform | head -1 | tr -s " " | cut -d " " -f1-3  | tail -1  > /tmp/tmp 
#	date_state_log=0 
#	nb_vm=1
#	level_appli=10000000
	
#	cat $log_state_platform | head -$id_line_state_log | tr -s " " | cut -d " " -f1-3  | tail -1  > /tmp/tmp 
#	read date_state_log_suivant nb_vm_suivant level_appli_suivant < /tmp/tmp
	
	
#	cat $log_gatling | grep REQUEST | tr "\t" " " |tr -s " " | cut -d ' ' -f 3,6,8-9 | sed 's/-/ ID/' | cut -d ' ' -f 2- | sed 's/^\(ID[0-9]*\) \([0-9]*\) \([0-9]*\) \(..\)$/\2 \1ID \4 D:\3 \1ID \4 F/' | tr ':' '\n' | sort -n | while read date id_req final_state type
#	do
#		
#		echo $date $id_req $final_state $type >> $file_sauvegarde_tmp
#		
#		if [ "$final_state" = "KO" ]
#		then
#			continue
#		fi
#		if [ "$date_depart_seconde" = "" ]
#		then
#			date_depart_seconde=$date
#			date_debut=$date
#		fi
#		if [ $date -ge `expr $date_depart_seconde + 1000` ]
#		then
#			#on change de seconde
#			
#			
#			
#			if [ $date -ge $date_state_log_suivant ]
#			then
#				date_state_log=$date_state_log_suivant 
#				nb_vm=$nb_vm_suivant 
#				level_appli=$level_appli_suivant
#				id_line_state_log=`expr $id_line_state_log + 1`
#				cat $log_state_platform | head -$id_line_state_log | tr -s " " | cut -d " " -f1-3  | tail -1  > /tmp/tmp 
#				read date_state_log_suivant nb_vm_suivant level_appli_suivant < /tmp/tmp
#				
#			fi	
#			
#			#on affiche  date debit_entrant debit_sortant nb_vm level_appli latence_moyenne
#			echo `expr $date_depart_seconde - $date_debut` $cpt_entrant $cpt_sortant $nb_vm $level_appli 0`bc -l <<< "$sum_rt / $cpt_rt"`
#			date_depart_seconde=$date
#			cpt_entrant=0
#			cpt_sortant=0
#			sum_rt=0
#			cpt_rt=0
#			
#		fi
#		
#		if [ "$type" = "D" ]
#		then
#			cpt_entrant=`expr $cpt_entrant + 1`
#		elif [ "$type" = "F" ]
#		then
#			cpt_sortant=`expr $cpt_sortant + 1`
#			#il faut ajouter son reponse time
#					
#			date_begin_request=`cat $file_sauvegarde_tmp | grep $id_req | grep "^.*D$" | cut -d ' ' -f1`
#			latence=`expr $date - $date_begin_request`
#			
#			
#			sum_rt=`expr $sum_rt + $latence`
#			cpt_rt=`expr $cpt_rt + 1`
#			
#		else
#			echo "error"
#			exit 2
#		fi
#	
#	done | tee $RESULT_BENCH/$exp/logs.dat
