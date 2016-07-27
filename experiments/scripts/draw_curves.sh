#!/bin/bash




usage="$0 <absolute_path_exp> [<date_begin_exp>]"
if [ $# -gt 2 ] || [ $# -lt 1 ]
then
	echo $usage
	exit 1
fi

EXP_PATH=$1
date_begin_exp=$2
cd $EXP_PATH

log_state_platform=state_plateforme.log	
repertoire_gatling=`ls | grep -E "\-[0-9]+"`
log_gatling=$repertoire_gatling/simulation.log

CURVE_PATH=$EXP_PATH/courbes




if [ -z "$date_begin_exp" ]
then
	date_begin_exp=`cat $log_gatling | grep REQUEST | tr "\t" " " |tr -s " " | cut -d ' ' -f 3,6,8-9 | cut -d ' ' -f 2,3 | tr ' ' '\n' | sort -n | head -1`
fi
date_end_exp=`cat $log_gatling | grep REQUEST | tr "\t" " " |tr -s " " | cut -d ' ' -f 3,6,8-9 | cut -d ' ' -f 2,3 | tr ' ' '\n' | sort -n | tail -1`


xmax=`expr $date_end_exp - $date_begin_exp`
xmax=`expr $xmax - 5000`

if [ -e $CURVE_PATH ]
then
	rm -rf $CURVE_PATH
fi
mkdir $CURVE_PATH

export SCRIPTS_PATH=$PROJECT_PATH/experiments/scripts


source $SCRIPTS_PATH/config_metrics.sh



for metric in `hgetkeys ylabel`
do
	num_col=`hget num_col $metric`
	ymax=`cat $EXP_PATH/logs.dat | cut -d ' ' -f $num_col | sort -n | tail -1`
	ymax=`bc -l <<<"$ymax * 1.1"`
	hput ymax "$metric" "$ymax"
	label_action=""
	while read date nb_vm level_appli action
	do
		if [ -z "$date" ]
		then
			continue
		fi
		sens=`echo $action | cut -d '_' -f2`	
		if [ "$sens" = "0" ]
		then
			continue
		elif [ "$sens" = "+" ]
		then
			color="rgb '#DBFFDA'"
		else
			color="rgb '#FFD4D4'"
		fi
		action=`echo $action | cut -d '_' -f1`
		x=`expr $date - $date_begin_exp`
		#x=0`bc <<<"$x / 1000"`
	
		if [ "$action" = "b" ]
		then
			x_begin=$x
		else
			x_end=$x		
			label_action=$label_action" set object rectangle from $x_begin,0 to $x_end,$ymax behind  fc $color :"
			#label_action=$label_action" set object rectangle from 0,40000 to 455345,40000 behind fc rgb '#FFD700' :"
		fi
		#set object rectangle from  0,0 to  4000,40000 behind fc rgb "#FFD700"
		#label_action=$label_action" set arrow from $x,0 to $x,1000 nohead lt $lt lw $lw :"
		
	done < $log_state_platform

	label_action=`echo $label_action | tr ':' '\n'`
	$SCRIPTS_PATH/gen_gnuplot.sh "$EXP_PATH/logs.dat" "$metric" "$CURVE_PATH" " " "`hget ylabel $metric`" "`hget num_col $metric`" "$label_action" "$ymax" "$xmax"
	gnuplot $CURVE_PATH/$metric.gnuplot
	ps2pdf $CURVE_PATH/$metric.ps $CURVE_PATH/$metric.pdf
	
done

