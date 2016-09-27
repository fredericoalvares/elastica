#!/bin/bash

#doit être executé  sur le cloud controler

#installation de redis
if [ "`env|grep PROJECT_PATH`" = "" ]
then
	echo "PROJECT_PATH is not defined"
	exit 2
fi

directory=$PROJECT_PATH/software_resources/redis
redis=redis-3.0.0

#on copie les fichiers redis dans un autre dossier (le nfs est en lecture seule)
sudo cp $directory/$redis.tar.gz /root/
sudo tar xvzf /root/$redis.tar.gz && sudo cp -r $redis /root/

#on build redis

cd /root/$redis
make distclean
make
cd /root

#on demonize redis 
cat /root/$redis/redis.conf | sed 's/daemonize no/daemonize yes/' > /tmp/redis.conf
mv /tmp/redis.conf /root/$redis/redis.conf

#on demarre redis avec la conf par defaut (sinon prevoir un fichier de conf a copier et a passer en argument a la commande)

/root/$redis/src/redis-server /root/$redis/redis.conf

