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

/share/elasticity_manager/handle_eventHybModes.sh `date +%s%N | cut -b1-13` $src $metric $val
