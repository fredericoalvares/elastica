#!/bin/bash

#sert à initier un handler d'event
src=$1
metric=$2
val=$3

if [ -z "$metric" ]
then
	exit 1
fi

if [ -z "$val" ]
then
	exit 1
fi
#
#IFS=':' read -a counter <<< "$val"

#echo "No mode: ${counter[0]} | Mode 0: ${counter[1]} | Mode 1: ${counter[2]} | Mode 2: ${counter[3]}" >> /share/elasticity_manager/rt_wiki_SLA.txt


#  ### HERE YOU SHOULD PUT YOUR CONDITIONS/CONSTRAINTS BASED ON THE SLA
#### AND CALL /root/action.sh BY PASSING AS ARGUMENT THE ELASTICITY LEVEL
#
#a=${counter[1]}
#b=${counter[2]}
#c=${counter[3]}
#
#recZeroFile='/share/elasticity_manager/r0.txt'
#recOneFile='/share/elasticity_manager/r1.txt'
#recTwoFile='/share/elasticity_manager/r2.txt'
#
#oldR0=$(cat "$recZeroFile")
#oldR1=$(cat "$recOneFile")
#oldR2=$(cat "$recTwoFile")
#
#if [ -f "$recZeroFile" ] && [ -f "$recOneFile" ] && [ -f "$recTwoFile" ]
#then
#x=`expr $a + $oldR0`
#y=`expr $b + $oldR1`
#z=`expr $c + $oldR2`
#   echo "$x" > "$recZeroFile"
#   echo "$y" > "$recOneFile"
#   echo "$z" > "$recTwoFile"
#fi
#
#
#per1=$(bc -l <<<"scale=2; $y*100/($x+$y+$z)")
#per2=$(bc -l <<<"scale=2; $z*100/($x+$y+$z)")
#echo "REC1 is $per1"
#echo "REC2 is $per2"
#
#echo "Perc rec1 $per1 % and Perc rec2 $per2 % " >> /share/elasticity_manager/rt_wiki_SLA.txt

/share/elasticity_manager/handle_eventHybModes.sh `date +%s%N | cut -b1-13` $src $metric $val
