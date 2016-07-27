#!/bin/bash

PROJECT_PATH=/share

while ! [ -e $PROJECT_PATH/common/util.sh  ]
do
	echo "Not found $PROJECT_PATH/common/util.sh"
#	sudo mount -t nfs 10.0.0.1:/share /share
	exit 1
done

source $PROJECT_PATH/common/util.sh

if [ "$#" -lt 1 ] 
then
   echo "Usage: $0 db_host port"
   exit 1
fi

DB_HOST=$1

level_file2=$(echo $LEVEL_FILE | sed "s/\//\\\\\//g")

sed "s/@@@DB_HOST@@@/$DB_HOST/g" $WWW_ROOT/PHP/PHPprinter.tpl |  sed "s/@@@DB_USER@@@/$DB_USER/g" | sed "s/@@@DB_PASSWORD@@@/$DB_PASSWORD/g" | sed "s/@@@DB_NAME@@@/$DB_NAME/g" | sed "s/@@@LEVEL_FILE@@@/$level_file2/g" > $WWW_ROOT/PHP/PHPprinter.php

