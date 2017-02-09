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

/share/elasticity_manager/non_adaptive_controller.sh `date +%s%N | cut -b1-13` $src $metric $val

#/share/elasticity_manager/responseTime_controller.sh `date +%s%N | cut -b1-13` $src $metric $val

#/share/elasticity_manager/green_hybrid_controller.sh `date +%s%N | cut -b1-13` $src $metric $val

# Depending on which controller we want to activate, we have to choose the name of the controller.
