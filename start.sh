#!/bin/bash
chemin=$(pwd)
chmod +x $chemin/script/installation.sh
chmod +x $chemin/script/host.sh
chmod +x $chemin/script/hostAlias.sh
chmod +x $chemin/playbook/playbook.sh

function initial() 
{
	echo "  ___         _      _     ___ ___ ___ "
	echo " / __| __ _ _(_)_ __| |_  |_  )_  )_  )"
	echo " \__ \/ _| '_| | '_ \  _|  / / / / / / "
	echo " |___/\__|_| |_| .__/\__| /___/___/___|"
	echo "               |_|                     "
	echo ""
	echo "1 - lancer l'installation des paquets"
	echo "2 - ajouter un host (nécessite l'installation des paquets)" 
	echo "3 - exécuter un playbook"
	echo "99 - exit"
	echo ""
	choix=$(zenity --width=320 --height=220 --list --column=numéro --column=option "1" "installation de paquets" "2" "ajouter un hôt"e "3" "exécuter un playbook" "99" "exit" --text="Que souhaitez vous faire?")
	#read choix
	if [ $choix == 1 ]
	then
		installation
	fi

	if [ $choix == 2 ]
	then
		host 
	fi 

	if [ $choix == 3 ]
	then
		playbook
	fi

	if [ $choix == 99 ]
	then
		echo ""
	fi
}
function playbook()
{
	./playbook/playbook.sh $(pwd) 
}
function installation()
{
	sudo apt update -y
	sudo apt upgrade -y
	$chemin/script/installation.sh $chemin
	echo ""
	initial
	echo ""
}
function configWin()
{
	if [ -e  /etc/ansible/group_vars/windows.yml ]
	then 
		echo "la configuration de windows existe déjà"
	else 
		if [ -d /etc/ansible/group_vars ]
		then
			echo "création de la configuration de windows"
			sudo touch /etc/ansible/group_vars/windows.yml
			sudo echo "ansible_user: ansible" | sudo tee -a /etc/ansible/group_vars/windows.yml
			sudo echo "ansible_password: ansible" | sudo tee -a /etc/ansible/group_vars/windows.yml
			sudo echo "ansible_port: 5985" | sudo tee -a /etc/ansible/group_vars/windows.yml
			sudo echo "ansible_connection: winrm" | sudo tee -a /etc/ansible/group_vars/windows.yml
			sudo echo "ansible_winrm_server_cert_validation: ignore" | sudo tee -a /etc/ansible/group_vars/windows.yml
			sudo echo "ansible_winrm_transport: basic" | sudo tee -a /etc/ansible/group_vars/windows.yml
		else 
			echo "création du répertoire group_vars et de la configuration de windows"
			sudo mkdir /etc/ansible/group_vars/
			sudo touch /etc/ansible/group_vars/windows.yml
			sudo echo "ansible_user: ansible" | sudo tee -a /etc/ansible/group_vars/windows.yml
			sudo echo "ansible_password: ansible" | sudo tee -a /etc/ansible/group_vars/windows.yml
			sudo echo "ansible_port: 5985" | sudo tee -a /etc/ansible/group_vars/windows.yml
			sudo echo "ansible_connection: winrm" | sudo tee -a /etc/ansible/group_vars/windows.yml
			sudo echo "ansible_winrm_server_cert_validation: ignore" | sudo tee -a /etc/ansible/group_vars/windows.yml
			sudo echo "ansible_winrm_transport: basic" | sudo tee -a /etc/ansible/group_vars/windows.yml
		fi
	fi
}
function configLinux()
{
	if [ -e  /etc/ansible/group_vars/$1.yml ]
	then 
		echo "la configuration de $1 existe déjà"
	else 
		if [ -d /etc/ansible/group_vars ]
		then
			echo "création de la configuration de $1"
			sudo touch /etc/ansible/group_vars/$1.yml
			sudo echo "ansible_connexion: ssh" | sudo tee -a /etc/ansible/group_vars/$1.yml
			sudo echo "ansible_ssh_user: ansible" | sudo tee -a /etc/ansible/group_vars/$1.yml
			sudo echo "ansible_ssh_pass: secret_password " | sudo tee -a /etc/ansible/group_vars/$1.yml
			sudo echo "ansible_python_interpreter: '/usr/bin/env python3'" | sudo tee -a /etc/ansible/group_vars/$1.yml
			sudo echo "ansible_become_method: sudo" | sudo tee -a /etc/ansible/group_vars/$1.yml
		else 
			echo "création du répertoire group_vars et de la configuration de $1"
			sudo mkdir /etc/ansible/group_vars/
			sudo touch /etc/ansible/group_vars/$1.yml
			sudo echo "ansible_connexion: ssh" | sudo tee -a /etc/ansible/group_vars/$1.yml
			sudo echo "ansible_ssh_user: ansible" | sudo tee -a /etc/ansible/group_vars/$1.yml
			sudo echo "ansible_ssh_pass: secret_password " | sudo tee -a /etc/ansible/group_vars/$1.yml
			sudo echo "ansible_python_interpreter: '/usr/bin/env python3'" | sudo tee -a /etc/ansible/group_vars/$1.yml
			sudo echo "ansible_become_method: sudo" | sudo tee -a /etc/ansible/group_vars/$1.yml
		fi
	fi
	
}
function goodIP()
{
	res=0
	ip=$1
	if [ $(awk -F"." '{print NF-1}' <<< "$ip") == 3 ]
	then
		longueur=${#ip}
		if [ $longueur -lt 16 ]
		then
			res=1
		fi
	fi
	return $res
}
function host()
{
	echo ""
	ansible --version 
	if [ $(echo "$?") == 0 ] 
	then
		echo "Dans quel groupe voulez vous mettre cette machine ?"
		host=$(zenity --entry --text="Dans quel groupe voulez vous mettre cette machine?")
		#read host 
		majHost=${host^^}
		if [ $majHost == "WINDOWS" ]
		then
			if [ -e /etc/ansible/group_vars/windows.yml ]
			then
				echo "Voulez-vous donner un alias à votre machine ? [O/N]"
				reponse=$(zenity --question --text="Voulez vous donner un alias à votre machine?")
				resul=$?
				echo " resul alias = $resul"
				#read reponse
				if [ $resul -eq 0 ]
				then
				#if [ $reponse == "O" -o $reponse == "o" -o $reponse == "oui" -o $reponse == "Oui" -o $reponse == "OUI" ]
					echo "Quel alias voulez-vous donner ?"
					surnom=$(zenity --entry --text="Quel alias voulez-vous donner?")
					#read surnom 
					aliasMaj=${surnom^^}
					if grep -w "$aliasMaj" "/etc/ansible/hosts" ; then
						echo "Cet alias existe déjà, veuillez le supprimer dans le fichier /etc/ansible/hosts ou choisir un autre alias"
						echo ""
					else
						echo "Quel est l'ip de la machine ?"
						ip=$(zenity --entry --text="Quelle est l'adresse IP de la machine?")
						#read ip 
						goodIP $ip
						ret=$?
						if [ $ret -eq 1 ]
						then
							./script/hostAlias.sh $host $aliasMaj $ip $chemin
						else
							echo "l'ip : $ip n'est pas valide"
							return 99
						fi
					fi
					if [ -e /etc/ansible/hosts ]
					then
						if grep -w "$host" "/etc/ansible/hosts" ; then
							echo "ce groupe  existe déjà, ajout de la machine dans le groupe"
							sudo sed -i "/$host/a $aliasMaj ansible_host=$ip" /etc/ansible/hosts
							sudo rm -f $chemin/script/file/hosts
							echo "ip ajouté au host" 
						else
							cat $chemin/script/file/hosts | sudo tee -a /etc/ansible/hosts
							sudo rm -f $chemin/script/file/hosts
							echo "done"
						fi
					else 
						sudo cp $chemin/script/file/hosts /etc/ansible/hosts
						sudo rm -f $chemin/script/file/hosts
						echo "done"
					fi
				else
					echo "Quel est l'ip de la machine ?"
					ip=$(zenity --entry --text="Quelle est l'adresse IP de la machine?")
					#read ip 
					goodIP $ip
					ret=$?
					if [ $ret -eq 1 ]
					then
						./script/host.sh $host $ip $chemin
					else
						echo "l'ip : $ip n'est pas valide veuillez recommencer"
						return 99
					fi
					if [ -e /etc/ansible/hosts ]
					then
						if grep -w "$host" "/etc/ansible/hosts" ; then
							echo "ce groupe  existe déja"
							sudo sed -i "/$host/a $ip" /etc/ansible/hosts
							sudo rm -f $chemin/script/file/hosts
							echo "ip ajouté au host" 
						else
							cat $chemin/script/file/hosts | sudo tee -a /etc/ansible/hosts
							sudo rm -f $chemin/script/file/hosts
							echo "done"
						fi
					else 
						sudo cp $chemin/script/file/hosts /etc/ansible/hosts
						sudo rm -f $chemin/script/file/hosts
						echo "done"
					fi
				fi
			else	
				configWin
				echo "Voulez-vous donner un alias à votre machine ? [O/N]"
				reponse=$(zenity --question --text="Voulez-vous donner un alias à votre machine?")
				resul=$?
			        #read reponse
				if [ $resul -eq 0 ]
				#if [ $reponse == "O" -o $reponse == "o" ]
				then 
					echo "Quel alias voulez-vous donner ?"
					surnom=$(zenity --entry --text="Quel alias voulez-vous donner?")
					#read surnom
					aliasMaj=${surnom^^}
					if grep -w "$aliasMaj" "/etc/ansible/hosts" ; then
						echo "Cet alias existe déjà, veuillez le supprimer dans le fichier /etc/ansible/hosts ou choisir un autre alias"
						echo ""
					else
						echo "Quel est l'ip de la machine ?"
						ip=$(zenity --entry --text="Quelle est l'adresse IP de votre machine?")
						#read ip 
						goodIP $ip
						ret=$?
						if [ $ret -eq 1 ]
						then
							./script/hostAlias.sh $host $aliasMaj $ip $chemin
						else
							echo "l'ip : $ip n'est pas valide veuillez recommencer"
							return 99
						fi
						if [ -e /etc/ansible/hosts ]
						then
							if grep -w "$host" "/etc/ansible/hosts" ; then
								echo "ce groupe  existe déja"
								sudo sed -i "/$host/a $aliasMaj ansible_host=$ip" /etc/ansible/hosts
								sudo rm -f $chemin/script/file/hosts
								echo "ip ajouté au host" 
							else
								cat $chemin/script/file/hosts | sudo tee -a /etc/ansible/hosts
								sudo rm -f $chemin/script/file/hosts
								echo "done"
							fi
						else 
							sudo cp $chemin/script/file/hosts /etc/ansible/hosts
							sudo rm -f $chemin/script/file/hosts
							echo "done"
						fi
					fi
				else
					echo "Quel est l'ip de la machine ?"
					ip=$(zenity --entry --text="Quelle est l'adresse IP de votre machine?")
					#read ip 
					goodIP $ip
					ret=$?
					if [ $ret -eq 1 ]
					then
						./script/host.sh $host $ip $chemin
					else
						echo "l'ip : $ip n'est pas valide veuillez recommencer"
						return 99
					fi
					if [ -e /etc/ansible/hosts ]
					then
						if grep -w "$host" "/etc/ansible/hosts" ; then
							echo "ce groupe  existe déja"
							sudo sed -i "/$host/a $ip" /etc/ansible/hosts
							sudo rm -f $chemin/script/file/hosts
							echo "ip ajouté au host" 
						else
							cat $chemin/script/file/hosts | sudo tee -a /etc/ansible/hosts
							sudo rm -f $chemin/script/file/hosts
							echo "done"
						fi
					else 
						sudo cp $chemin/script/file/hosts /etc/ansible/hosts
						sudo rm -f $chemin/script/file/hosts
						echo "done"
					fi
				fi
			fi
		else
			if [ $majHost == "LINUX" -o $majHost == "UBUNTU" -o $majHost == "DEBIAN" -o $majHost == "KALI" ]
			then 
				configLinux $host
			fi
			echo "Voulez-vous donner un alias à votre machine ? [O/N]"
			reponse=$(zenity --question --text="Voulez-vous donner un alias à votre machine?")
			resul=$?
			if [ $resul -eq 0 ]
			then
			#if [ $reponse == "O" -o $reponse == "o" ]
			#then
				echo "Quel alias voulez-vous donner ?"
				surnom=$(zenity --entry --text="Quel alias voulez-vous donner?")
				#read surnom 
				aliasMaj=${surnom^^}
				if grep -w "$aliasMaj" "/etc/ansible/hosts" ; then
					echo "Cet alias existe déjà, veuillez le supprimer dans le fichier /etc/ansible/hosts ou choisir un autre alias"
					echo ""
				else
					echo "Quel est l'ip de la machine ?"
					ip=$(zenity --entry --text="Quelle est l'ip de la machine?")
					#read ip 
					goodIP $ip
					ret=$?
					if [ $ret -eq 1 ]
					then
						./script/hostAlias.sh $host $aliasMaj $ip $chemin
					else
						echo "l'ip : $ip n'est pas valide veuillez recommencer"
						return 99
					fi 
					if [ -e /etc/ansible/hosts ]
					then
						if grep -w "$host" "/etc/ansible/hosts" ; then
							echo "ce groupe  existe déja"
							sudo sed -i "/$host/a $aliasMaj ansible_host=$ip" /etc/ansible/hosts
							sudo rm -f $chemin/script/file/hosts
							echo "ip ajouté au host" 
						else
							cat $chemin/script/file/hosts | sudo tee -a /etc/ansible/hosts
							sudo rm -f $chemin/script/file/hosts
							echo "done"
						fi
					else 
						sudo cp $chemin/script/file/hosts /etc/ansible/hosts
						sudo rm -f $chemin/script/file/hosts
						echo "done"
					fi
				fi
			else
				echo "Quel est l'ip de la machine ?"
				ip=$(zenity --entry --text="Quelle est l'ip de la machine?")
				#read ip 
				goodIP $ip
				ret=$?
				if [ $ret -eq 1 ]
				then
					./script/host.sh $host $ip $chemin
				else
					echo "l'ip : $ip n'est pas valide veuillez recommencer"
					return 99
				fi
				if [ -e /etc/ansible/hosts ]
				then
					if grep -w "$host" "/etc/ansible/hosts" ; then
						echo "ce groupe  existe déja"
						sudo sed -i "/$host/a $ip" /etc/ansible/hosts
						sudo rm -f $chemin/script/file/hosts
						echo "ip ajouté au host" 
					else
						cat $chemin/script/file/hosts | sudo tee -a /etc/ansible/hosts
						sudo rm -f $chemin/script/file/hosts
						echo "done"
					fi
				else 
					sudo cp $chemin/script/file/hosts /etc/ansible/hosts
					sudo rm -f $chemin/script/file/hosts
					echo "done"
				fi
	
			fi
		fi
	else 
		echo "Si vous voulez ajouter des host veuillez lancer l'installation au préallable"
	fi
	
	echo ""
	initial
	echo ""
}

initial


