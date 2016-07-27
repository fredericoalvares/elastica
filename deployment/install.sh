#!/bin/bash

#doit etre execute sur la fontend du site g5k

#if [ "`env | grep "OAR_NODE_FILE"`" = "" ]
#then
	#echo "doit etre execute sur la machine frontale du site en question"
#	exit 1
#fi


if [ "`env|grep PROJECT_PATH`" = "" ]
then
	echo "PROJECT_PATH is not defined, using ~/elastica"
	export PROJECT_PATH=~/elastica
fi
cd $PROJECT_PATH

COMMON_PATH=$PROJECT_PATH/common

source $COMMON_PATH/util.sh



if [ "`env | grep "OAR_NODE_FILE"`" = "" ]
then
    if [ $# -ne 1 ]
    then
        echo "You are not connected to a JOB. Please connect to a JOB or provide a JOB ID!"
        echo $0 job_id
        exit 1
    else
        JOB_ID=$1
 #       oarstat -f -j $JOB_ID | grep assigned_hostnames | awk '{print $3}' | tr '+' '\n' > $RESERVATION_NODES_FILE
    fi
else
    JOB_ID=$OAR_JOBID
#    RESERVATION_NODES_FILE=$OAR_NODEFILE
fi

kavlan -j $JOB_ID -l > $RESERVATION_NODES_FILE
cp $RESERVATION_NODES_FILE  $KVLAN_NODES_FILE 

if [ ! -f "$RESERVATION_NODES_FILE" ]
then
    echo "File $RESERVATION_NODES_FILE not found, you should execute the \$ELASTICA_HOME/setup.sh script"
    exit 1
fi

#Stores user and password
if ! [ -f $G5K_USER_PATH -a -f $G5K_PWD_PATH ]
then
    source $PROJECT_PATH/deployment/usr_pwd.sh
fi




numkavlan=$(kavlan -j $JOB_ID -V)
site=$(hostname | cut -d. -f2)

name_controler=""

#KVLAN_NODES_FILE=~/kavlan_nodes
NOVA_TMP='/tmp/tmp'$(date +%s)
#rm -f /tmp/kavlan_nodes
#rm -f $KVLAN_NODES_FILE

for host in `cat $RESERVATION_NODES_FILE | sort | uniq`
do
#        host_kavlan=`echo $host | sed "s/^\(.*\)\(\.$site.*\)$/\1-kavlan-$numkavlan\2/"`
	is_controler=`ssh root@$host 'ls ~ | grep openrc'`
        if [ ! -z $is_controler ]
        then
#            name_controler=$host_kavlan
            name_controler=$host
        fi
#	echo "$host_kavlan" >>  $KVLAN_NODES_FILE
done

#NODES=`cat /tmp/kavlan_nodes`
extra_injectors=`expr $NUMBER_APPLICATIONS - 1`
NODES=$(sed '1,'$extra_injectors'd' $KVLAN_NODES_FILE)
sed -n '1,'$extra_injectors'p'  $KVLAN_NODES_FILE > $INJECTOR_NODES_FILE

for node in $NODES; do 
echo $node 
	tmp=`ssh root@$node 'cat /etc/passwd | grep nova'`
	scp ~/.ssh/id_rsa* root@$node:~/.ssh	
	if [ "$tmp" = ""  ]
	then
	   echo "$node is not an OpenStack machine or the installation failed"
# 	   echo "$node" >> $INJECTOR_NODES_FILE
	else
	  ssh root@$node "usermod -s /bin/bash nova"
	  ssh root@$node 'su nova -c "echo \$HOME" ' > $NOVA_TMP
	  nova_home=`cat $NOVA_TMP`
	  echo $nova_home
	  ssh root@$node "rm -rf $nova_home/.ssh"
	  ssh root@$node "mkdir $nova_home/.ssh"
	  scp ~/.ssh/id_rsa* root@$node:$nova_home/.ssh
	  ssh root@$node "cat $nova_home/.ssh/id_rsa.pub > $nova_home/.ssh/authorized_keys"
	  ssh root@$node "echo Host \* > $nova_home/.ssh/config"
	  ssh root@$node "echo ' StrictHostKeyChecking no' >> $nova_home/.ssh/config"
	  ssh root@$node "echo ' UserKnownHostsFile=/dev/null' >> $nova_home/.ssh/config"
	  ssh root@$node "chgrp nova -R $nova_home/.ssh/"	
	  ssh root@$node "chown nova -R $nova_home/.ssh/"	
	fi
done


echo "@@@@@@ INJECTORS @@@@@@@"
for node in $(cat $INJECTOR_NODES_FILE); do 
      echo $node
      ssh root@$node "echo ' StrictHostKeyChecking no' >> ~/.ssh/config"
      ssh root@$name_controler "echo ' StrictHostKeyChecking no' >> ~/.ssh/config"

      #on installe java
      ssh root@$node "apt-get -y install openjdk-7-jre-headless"
      
      scp -r $PROJECT_PATH/gatling root@$node:~/

      #on declare le PROJECT_PATH local dans le .bashrc
      #ssh root@$name_controler "echo 'export PROJECT_PATH=/share' >> /root/.bashrc"
      ssh root@$node "echo 'ulimit -n 65535' >> /root/.bashrc"
	
      ssh root@$node "echo 'fs.file-max =  100000' >> /etc/sysctl.conf; \
                                  echo 'net.ipv4.ip_local_port_range="1025 65535"' >> /etc/sysctl.conf; \
                                  echo '*    soft     nofile   65536' >> /etc/security/limits.conf; \
                                  echo '*    hard     nofile   65536' >> /etc/security/limits.conf; \
                                  echo 'session    required   pam_limits.so' >> /etc/pam.d/common-session; \
 				  echo 'session    required   pam_limits.so' >> /etc/pam.d/common-session-noninteractive; \
				  echo 300000 | sudo tee /proc/sys/fs/nr_open; \
				  echo 300000 | sudo tee /proc/sys/fs/file-max; \
                                  sysctl -p"
done

#on autorise l'execution du .bashrc en connexion non interactive
ssh root@$name_controler "cat .bashrc | sed 's/^.*PS1.*return.*$//' > $NOVA_TMP && mv $NOVA_TMP ~/.bashrc"

#on verifie si on a pas déja fait le déploiement nova
ok=`ssh root@$name_controler "cat ~/.bashrc | grep 'openrc'"`



if [ -z "$ok" ]
then
	scp "$PATH_IMAGE_VM/$FILE_IMAGE_VM" root@$name_controler:/tmp
	ssh root@$name_controler "echo 'source ~/openrc' >> ~/.bashrc"
	ssh root@$name_controler "echo 'export http_proxy=\"http://proxy:3128\"' >> ~/.bashrc"
	ssh root@$name_controler "echo 'export https_proxy=\"http://proxy:3128\"' >> ~/.bashrc"
	ssh root@$name_controler "glance add name='Ubuntu-12.04' is_public='true' container_format='ovf' disk_format='qcow2' < /tmp/$FILE_IMAGE_VM"
	ssh root@$name_controler "ssh-keygen -f $PATH_KEYPAIR/id_rsa -t rsa -N ''"

	ssh root@$name_controler "nova keypair-add --pub_key $PATH_KEYPAIR/id_rsa.pub $key"
	ssh root@$name_controler "nova secgroup-create $sec_group ' default security goup'"
	ssh root@$name_controler "nova secgroup-add-rule $sec_group tcp 22 22 0.0.0.0/0"
	ssh root@$name_controler "nova secgroup-add-rule $sec_group tcp 80 80 0.0.0.0/0"
	ssh root@$name_controler "nova secgroup-add-rule $sec_group icmp -1 -1 0.0.0.0/0"
			
	#on installe le serveur nfs sur le cloud controler
	ssh root@$name_controler "apt-get -y install portmap nfs-common nfs-kernel-server"
	ssh root@$name_controler "mkdir /share"
	ssh root@$name_controler "chmod 777 /share"
	ssh root@$name_controler "echo '/share *(ro)' >> /etc/exports"
	ssh root@$name_controler "service nfs-kernel-server restart"
	
	#on installe java
	ssh root@$name_controler "apt-get -y install openjdk-7-jre-headless"
	
	#on telecharge le PROJECT_PATH sur le /share
	scp -r $PROJECT_PATH/* root@$name_controler:/share/
	
	#on declare le PROJECT_PATH local dans le .bashrc
	ssh root@$name_controler "echo 'export PROJECT_PATH=/share' >> /root/.bashrc"
	ssh root@$name_controler "echo 'ulimit -n 65535' >> /root/.bashrc"
	
        ssh root@$name_controler "echo 'fs.file-max =  100000' >> /etc/sysctl.conf; \
                                  echo 'net.ipv4.ip_local_port_range="1025 65535"' >> /etc/sysctl.conf; \
                                  echo '*    soft     nofile   65536' >> /etc/security/limits.conf; \
                                  echo '*    hard     nofile   65536' >> /etc/security/limits.conf; \
                                  echo 'session    required   pam_limits.so' >> /etc/pam.d/common-session; \
 				  echo 'session    required   pam_limits.so' >> /etc/pam.d/common-session-noninteractive; \
				  echo 300000 | sudo tee /proc/sys/fs/nr_open; \
				  echo 300000 | sudo tee /proc/sys/fs/file-max; \
                                  sysctl -p"

	#on install et on demare redis
	ssh root@$name_controler "chmod +x /share/software_resources/redis/install.sh"
	ssh root@$name_controler "/share/software_resources/redis/install.sh"
	
	#on install et on demare un logstash
	logstash=logstash-1.4.2
	directory=/share/software_resources/logstash
	ssh root@$name_controler "cp $directory/$logstash.tar.gz $DEFAULT_LOCAL_CONF_PATH/"
	ssh root@$name_controler "cp $directory/indexer_logstash.conf $DEFAULT_LOCAL_CONF_PATH/"


	
	
	ssh root@$name_controler "tar xvzf $DEFAULT_LOCAL_CONF_PATH/$logstash.tar.gz && cp -r $logstash $DEFAULT_LOCAL_CONF_PATH/"
	ssh root@$name_controler "rm -f /tmp/flag && touch /tmp/flag"
	ssh root@$name_controler "$DEFAULT_LOCAL_CONF_PATH/$logstash/bin/logstash agent -f \"$DEFAULT_LOCAL_CONF_PATH/indexer_logstash.conf\" > /tmp/stdout_logstash 2> /tmp/stderr_logstash" &
	
	ssh root@$name_controler "/share/elasticity_manager/server.sh && rm -f /tmp/flag" &
	
	#on ferme la connexion
	echo -n "closing conection"
	while [ `ssh  root@$name_controler "[ -e /tmp/flag ]"`  ]
	do
		echo -n "."
	done
	tokill=`ps aux | grep  'bin/logstash agent -f' | grep -v "grep" | tr -s ' ' | cut -d ' ' -f 2`
	kill -9 $tokill
	
	tokill=`ps aux | grep  'elasticity_manager/server.sh' | grep -v "grep" | tr -s ' ' | cut -d ' ' -f 2`
	kill -9 $tokill
	
	echo -n "conection closed"
	
	
	
	
	
fi

echo "Installation of elastica done. To connect to the cloud controller : ssh root@$name_controler"



