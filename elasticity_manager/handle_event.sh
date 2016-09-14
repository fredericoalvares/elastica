#!/bin/bash

# sert à traiter les evenement : POUR L'INSTANT ON NE S'OCCUPE QUE DU RESPONSE TIME
#seuils en secondes

thr_1=5.0
thr_2=15.0

#Read the file

timestamp=$1 
metric=$2
val=$3

echo "handle_event debut : $timestamp $metric $val"

if [ "$metric" = "energy" ]
then
  if [ `bc -l <<<"$thr_1 > $val"` -eq 1 ]
  then
        sens="0"
        echo "No energy!"      
  elif [ `bc -l <<<"$thr_2 < $val"` -eq 1 ]
  then
	sens="0" 
        echo "Enough energy!!"
  else
	sens="0"
        echo "Moderate energy!!"
  fi
  /root/action.sh $sens
 


fi




#on met un temps de calme égal au tempde fenetre de monitoring
#sleep 30
