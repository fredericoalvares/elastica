#!/bin/bash

#doit être executé  sur le cloud controler

#instalation de mysql

if [ "`env|grep PROJECT_PATH`" = "" ]
then
	echo "PROJECT_PATH is not defined"
	exit 2
fi
source $PROJECT_PATH/software_resources/header_install.sh



ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo apt-get -y update;\
                                               sudo apt-get install debconf-utils;\
                                               echo \"mysql-server-5.5 mysql-server/root_password_again password $DB_ROOT_PASSWORD\" | sudo debconf-set-selections;\
                                               echo \"mysql-server-5.5 mysql-server/root_password password $DB_ROOT_PASSWORD\" | sudo debconf-set-selections;\
                                               sudo apt-get -y install mysql-server libmysqlclient-dev;\
 				               sudo sed -i.bak \"s/\(^.*bind-address.*$\)/#\1/g\" /etc/mysql/my.cnf;\
                                               sudo sed -i.bak \"/\[mysqld\]/a\\max_connections \= 250\" /etc/mysql/my.cnf"

ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo /bin/su -c \"echo 'net.ipv4.ip_local_port_range=1025 65535' >> /etc/sysctl.conf\"; \
                                               sudo /bin/su -c \"echo 'fs.file-max = 100000' >> /etc/sysctl.conf\"; \
					       sudo /bin/su -c \"echo 'net.core.somaxconn = 1024' >> /etc/sysctl.conf\"; \
                                               sudo /bin/su -c \"echo '*    soft     nofile   65536' >> /etc/security/limits.conf\"; \
                                               sudo /bin/su -c \"echo '*    hard     nofile   65536' >> /etc/security/limits.conf\"; \
                                               sudo /bin/su -c \"echo 'session    required   pam_limits.so' >> /etc/pam.d/common-session\"; \
                                               sudo /bin/su -c \"echo 'session    required   pam_limits.so' >> /etc/pam.d/common-session-noninteractive\"; \
                                  sudo /bin/su -c \"echo 300000 | sudo tee /proc/sys/fs/nr_open\"; \
                                  sudo /bin/su -c \"echo 300000 | sudo tee /proc/sys/fs/file-max\"; \
                                  sudo sysctl -p"


cmd="sudo mysql_config --socket;sudo service mysql restart"

#on demare nginx
ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo $cmd"


#sauvegarde dans le script de démarage
#ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo echo \"$cmd\" >> $script_start_services"




