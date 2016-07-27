if [ -f /tmp/commandes ]
then
	echo "setting start commande"
	#on démare le service
	#ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo $cmd"
	#on sauvegarde dans le script de démarage
	while read line
	do
		echo "setting : $line"
		ssh ubuntu@$ip_adress -i $PATH_KEYPAIR/id_rsa "sudo echo \"$line\" >> $script_start_services"
	done < /tmp/commandes
fi
