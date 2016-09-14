#!/bin/bash

#doit être executé  sur le cloud controler

#instalation de nginx

if [ "`env|grep PROJECT_PATH`" = "" ]
then
	echo "PROJECT_PATH is not defined"
	exit 2
fi
source $PROJECT_PATH/software_resources/header_install.sh

ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "http_proxy="http://proxy.lyon.grid5000.fr:3128" https_proxy="http://proxy.lyon.grid5000.fr:3128" sudo -E add-apt-repository ppa:nginx/stable -y;\
sudo apt-get -y update; \
sudo apt-get -y install php5-common php5-cli php5-fpm php5-mysql nginx"

www_root2=$(echo $WWW_ROOT | sed "s/\//\\\\\//g")

nb_proc=$(ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo grep ^proces /proc/cpuinfo | wc -l")

sed "s/@@@PORT@@@/$WORKER_PORT/g" $PROJECT_PATH/software_resources/php/nginx.tpl | sed "s/@@@WWW_ROOT@@@/$www_root2/g" | sed "s/@@@PROCESSES@@@/$nb_proc/g" > $PROJECT_PATH/software_resources/php/nginx.conf

scp -i $PATH_KEYPAIR/id_rsa $PROJECT_PATH/software_resources/php/nginx.conf ubuntu@$ip_adress:$PHP_NGINX_CONF 
#cp ~/nginx.conf $PHP_NGINX_CONF;
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo mkdir -p $WWW_ROOT"
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo chmod 777 $WWW_ROOT"
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo /bin/su -c \"echo 'fs.file-max = 100000' >> /etc/sysctl.conf\""
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo /bin/su -c \"echo 'net.core.somaxconn = 1024' >> /etc/sysctl.conf\""
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo /bin/su -c \"echo 'net.ipv4.ip_local_port_range=1025 65535' >> /etc/sysctl.conf\"" 
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo /bin/su -c \"echo 'net.ipv4.tcp_tw_recycle = 1' >> /etc/sysctl.conf\""
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo /bin/su -c \"echo 'net.ipv4.tcp_tw_reuse = 1' >> /etc/sysctl.conf\""
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo /bin/su -c \"echo 'net.core.rmem_max = 16777216' >> /etc/sysctl.conf\""
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo /bin/su -c \"echo 'net.core.wmem_max = 16777216' >> /etc/sysctl.conf\""
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo /bin/su -c \"echo 'net.ipv4.tcp_max_syn_backlog = 4096' >> /etc/sysctl.conf\"" 
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo /bin/su -c \"echo 'net.ipv4.tcp_syncookies = 1' >> /etc/sysctl.conf\""
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo /bin/su -c \"echo '*    soft     nofile   65536' >> /etc/security/limits.conf\""
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo /bin/su -c \"echo '*    hard     nofile   65536' >> /etc/security/limits.conf\""
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo /bin/su -c \"echo 'root    soft     nofile   65536' >> /etc/security/limits.conf\""
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo /bin/su -c \"echo 'root    hard     nofile   65536' >> /etc/security/limits.conf\"" 
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo /bin/su -c \"echo 'session    required   pam_limits.so' >> /etc/pam.d/common-session\"" 
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo /bin/su -c \"echo 'session    required   pam_limits.so' >> /etc/pam.d/common-session-noninteractive\""
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo /bin/su -c \"echo 300000 | sudo tee /proc/sys/fs/nr_open\""
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo /bin/su -c \"echo 300000 | sudo tee /proc/sys/fs/file-max\"" 
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo /bin/su -c \"sed -i.bak 's/^.*rlimit_files.*$/rlimit_files\=65536/' /etc/php5/fpm/php-fpm.conf\"" 
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo /bin/su -c \"sed -i.bak 's/^pm\.max_children.*$/pm\.max_children \= 50/' /etc/php5/fpm/pool.d/www.conf\""      
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo /bin/su -c \"sed -i.bak 's/^;pm\.max_requests.*$/pm\.max_requests \= 500/' /etc/php5/fpm/pool.d/www.conf\"" 
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo sysctl -p"

cmd="sudo service nginx stop;sudo service php5-fpm start;sudo nginx -c $PHP_NGINX_CONF"

#on demare nginx
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo $cmd"


#sauvegarde dans le script de démarage
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo echo \"$cmd\" >> $script_start_services"




