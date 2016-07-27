#!/bin/bash

#sert à initier un handler d'event
metric=$1
val=$2

if [ -z "$metric" ]
then
	exit 1
fi

if [ -z "$val" ]
then
	exit 1
fi

/share/elasticity_manager/exp.sh `date +%s%N | cut -b1-13` $metric $val
