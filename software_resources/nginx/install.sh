#!/bin/bash

#doit être executé  sur le cloud controler

#instalation de nginx

if [ "`env|grep PROJECT_PATH`" = "" ]
then
	echo "PROJECT_PATH is not defined"
	exit 2
fi
source $PROJECT_PATH/software_resources/header_install.sh


scp -i $PATH_KEYPAIR/id_rsa $PROJECT_PATH/software_resources/nginx/* ubuntu@$ip_adress:$NGINX_CONF_PATH/ 

#ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo cp -r  $PROJECT_PATH/software_resources/nginx/* $NGINX_CONF_PATH/"

ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "http_proxy="http://proxy.lyon.grid5000.fr:3128" https_proxy="http://proxy.lyon.grid5000.fr:3128" sudo -E add-apt-repository ppa:nginx/stable -y;\
sudo apt-get -y update;\
sudo apt-get -y install nginx"

#scp -i $PATH_KEYPAIR/id_rsa $PROJECT_PATH/software_resources/nginx/nginx.tpl $PROJECT_PATH/software_resources/nginx/lb-setup.sh ubuntu@$ip_adress:~/



ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo /bin/su -c \"echo 'fs.file-max = 100000' >> /etc/sysctl.conf\"; \
                               sudo /bin/su -c \"echo 'net.core.somaxconn = 1024' >> /etc/sysctl.conf\"; \
			       sudo /bin/su -c \"echo 'net.ipv4.ip_local_port_range=1025 65535' >> /etc/sysctl.conf\"; \
			       sudo /bin/su -c \"echo 'net.ipv4.tcp_tw_recycle = 1' >> /etc/sysctl.conf\"; \
			       sudo /bin/su -c \"echo 'net.ipv4.tcp_tw_reuse = 1' >> /etc/sysctl.conf\"; \
			       sudo /bin/su -c \"echo 'net.core.rmem_max = 16777216' >> /etc/sysctl.conf\"; \
			       sudo /bin/su -c \"echo 'net.core.wmem_max = 16777216' >> /etc/sysctl.conf\"; \
			       sudo /bin/su -c \"echo 'net.ipv4.tcp_max_syn_backlog = 4096' >> /etc/sysctl.conf\"; \
			       sudo /bin/su -c \"echo 'net.ipv4.tcp_syncookies = 1' >> /etc/sysctl.conf\"; \
                               sudo /bin/su -c \"echo '*    soft     nofile   65536' >> /etc/security/limits.conf\"; \
                               sudo /bin/su -c \"echo '*    hard     nofile   65536' >> /etc/security/limits.conf\"; \
                               sudo /bin/su -c \"echo 'root    soft     nofile   65536' >> /etc/security/limits.conf\"; \
                               sudo /bin/su -c \"echo 'root    hard     nofile   65536' >> /etc/security/limits.conf\"; \
                               sudo /bin/su -c \"echo 'session    required   pam_limits.so' >> /etc/pam.d/common-session\"; \
                               sudo /bin/su -c \"echo 'session    required   pam_limits.so' >> /etc/pam.d/common-session-noninteractive\"; \
              		       sudo /bin/su -c \"echo 300000 | sudo tee /proc/sys/fs/nr_open\"; \
                     	       sudo /bin/su -c \"echo 300000 | sudo tee /proc/sys/fs/file-max\"; \
                               sudo sysctl -p"

#sed "s/@@@PORT@@@/8080/g" $NGINX_TPL | sed "s/@@@WORKERS@@@/$ADDED_SERVERS/g" > $NGINX_CONF

cmd="service nginx stop"

#on demare nginx
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo $cmd"

#sauvegarde dans le script de démarage
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo echo \"$cmd\" >> $script_start_services"
