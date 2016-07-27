#!/bin/bash

# sert à traiter les evenement : POUR L'INSTANT ON NE S'OCCUPE QUE DU RESPONSE TIME
#seuils en secondes

# The files where the no of request associated with modes will be stored
recZeroFile='/share/elasticity_manager/r0.txt'
recOneFile='/share/elasticity_manager/r1.txt'
recTwoFile='/share/elasticity_manager/r2.txt'

# SLA target for recommendation, depending what we put here!
rec1=50
rec2=30

#Read the file
oldR0=$(cat "$recZeroFile")
oldR1=$(cat "$recOneFile")
oldR2=$(cat "$recTwoFile")

timestamp=$1 
metric=$2
val=$3

echo "handle_event debut : $timestamp $metric $val"

if [ "$metric" = "modes" ]
then
  IFS=':' read -a counter <<< "$val"
   
  echo "No mode: ${counter[0]} | Mode 0: ${counter[1]} | Mode 1: ${counter[2]} | Mode 2: ${counter[3]}"
  ### HERE YOU SHOULD PUT YOUR CONDITIONS/CONSTRAINTS BASED ON THE SLA
### AND CALL /root/action.sh BY PASSING AS ARGUMENT THE ELASTICITY LEVEL

a=${counter[1]}
b=${counter[2]}
c=${counter[3]}

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
else
 sens="0"

fi
    /root/action.sh $sens
echo "Perc rec1 $per1 % and Perc rec2 $per2 %, distance for rec1 $temp1% and distance for rec2 is $temp2% " >> /share/elasticity_manager/SLA.txt

fi



# /root/action.sh $sens
# echo "Perc rec1 $per1 % and Perc rec2 $per2 %, distance for rec1 $temp1% and distance for rec2 is $temp2% " >> /share/elasticity_manager/SLA.txt





#on met un temps de calme égal au tempde fenetre de monitoring
#sleep 30
