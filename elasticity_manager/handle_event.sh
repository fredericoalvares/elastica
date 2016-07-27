#!/bin/bash

# sert à traiter les evenement : POUR L'INSTANT ON NE S'OCCUPE QUE DU RESPONSE TIME
#seuils en secondes

thr_1=5.0
thr_2=15.0

#Read the file
oldR0=$(cat "$recZeroFile")
oldR1=$(cat "$recOneFile")
oldR2=$(cat "$recTwoFile")

timestamp=$1 
metric=$2
val=$3

echo "handle_event debut : $timestamp $metric $val"

if [ "$metric" = "energy" ]
then
  if [ `bc -l <<<"$thr_1 > $val"` -eq 1 ]
  then
        sens="0"      
  elif [ `bc -l <<<"$thr_2 < $val"` -eq 1 ]
  then
	sens="2" 
  else
	sens="1"
  fi
  /root/action.sh $sens
 
       a=$val

            if [ "$a" -e 0 ]
                then 
                   echo "No green energy"
            elif [ "$Thr_1" -ge "$a" ]
                then  
                 dimmer=$(bc -l <<<"scale=0; ($a*100)/$thr_1")
            else
                 dimmer=$(bc -l <<<"scale=0; ($a*100)/$thr_2")
            fi
            


fi




#on met un temps de calme égal au tempde fenetre de monitoring
#sleep 30
