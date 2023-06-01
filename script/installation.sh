#!/bin/bash
echo "installation ansible" 
sudo apt install -y ansible
echo ""
echo "création répertoire ansible" 
sudo mkdir /etc/ansible/
sed "s/\#host\_key\_checking/host\_key\_checking/g" $1/script/file/ansible.cfg > $1/script/file/ansible2.cfg
sudo cp $1/script/file/ansible2.cfg /etc/ansible/ansible.cfg
sudo rm -f $1/script/file/ansible2.cfg
echo ""
echo "installation pip"
sudo apt install -y pip
if [ $? == 0 ]
then 
	sudo apt install -y python3-pip
	echo "installation pywinrm"
	sudo pip install "pywinrm[credssp]"
	echo ""
	if [ $? == 0 ]
	then 
		echo "done" 
	else 
		echo "adaptation de la cryptography"
		sudo pip install -U cryptography
		echo ""
	fi
else 
	echo "erreur d'installation pour pip, veuillez vérifier que le serveur ftp est accessible"
fi
echo "installation de SSHPASS"
sudo apt install -y sshpass
echo ""
