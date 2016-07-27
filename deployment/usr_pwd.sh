#!/bin/sh

if [ "`env|grep PROJECT_PATH`" = "" ]
then
    echo "PROJECT_PATH is not defined, using ~/elastica"
    export PROJECT_PATH=~/elastica
fi

source $PROJECT_PATH/common/util.sh



echo "Using $USER as username"

if [ -f $G5K_USER_PATH ]
then
   echo "Username already defined. Overwriting..."
fi

echo $USER > $G5K_USER_PATH

stty_orig=`stty -g` # save original terminal setting.
echo "Plase enter your password: "
stty -echo          # turn-off echoing.
read passwd         # read the password
stty $stty_orig
echo "Plase confirm your password: "
stty -echo          # turn-off echoing.
read passwd_conf         # read the password
stty $stty_orig

if ! [ "$passwd_conf" = "$passwd" ]
then
   exit 1
fi

enc_pwd=$(echo $passwd | base64)

echo $enc_pwd > $G5K_PWD_PATH

echo "Prepare script successfully executed!"

check=$(cat $G5K_PWD_PATH | base64 --decode)

if ! [ "$check" = "$passwd" ]
then
   echo "Error !"
fi



