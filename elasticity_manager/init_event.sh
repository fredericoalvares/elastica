#!/bin/bash

#sert à initier un handler d'event
read metric val
if [ -z "$metric" ]
then
	exit 1
fi

if [ -z "$val" ]
then
	exit 1
fi

/share/elasticity_manager/handle_eventHyb.sh `date +%s%N | cut -b1-13` $metric $val
