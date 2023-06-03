#!/bin/bash 
chemin=$1/playbook
function addUser()
{
	echo "Sur quelle machine (alias) voulez-vous exécuter le playbook ?"
	host=$(zenity --entry --text="Sur quelle machine (alias) voulez-vous éxécuter le playbook?")
	ret1=$?
	if [ $ret1 == 1 ]
	then 
		return 99
	fi
	majHost=${host^^}
	echo "Quel est  le nom de l'utilisateur à ajouter ?" 
	name=$(zenity --entry --text="Quel est le nom de l'utilisateur à ajouter?")
	ret2=$?
	if [ $ret2 == 1 ]
	then 
		return 99
	fi
	echo "Quel est le mot de passe de l'utilisateur ?"
	password=$(zenity --entry --text="Quel est le mot de passe de l'utilisateur $name?")
	ret3=$?
	if [ $ret3 == 1 ]
	then 
		return 99
	fi
	cp $chemin/adduser.yml $chemin/backup.yml
	sed -i "s/ExampleHost/$majHost/g" $chemin/backup.yml
	sed -i "s/ExampleUserName/$name/g" $chemin/backup.yml
	sed -i "s/ExampleUserPassword/$password/g" $chemin/backup.yml
	ansible-playbook $chemin/backup.yml
	rm $chemin/backup.yml
}
function firefox()
{
	echo "Voulez-vous déployer firefox sur une seule machine ou sur un groupe entier ? [Machine/Groupe]"
	reponse=$(zenity --entry --text="Voulez-vous déployer firefox sur une seule machine ou sur un groupe entier ? [Machine/Groupe]")
	ret=$?
	if [ $ret == 1 ]
	then
		return 99
	fi
	majReponse=${reponse^^}
	if [ $majReponse == "MACHINE" -o $majReponse == "M" ]
	then
		echo "Sur quelle machine (alias) voulez-vous exécuter le playbook ?"
		host=$(zenity --entry --text="Sur quelle machine (alias) voulez-vous éxécuter le playbook?")
		ret=$?
		if [ $ret == 1 ]
		then
			return 99
		fi
		majHost=${host^^}
		cp $chemin/firefox.yml $chemin/backupFirefox.yml
		sed -i "s/ExampleHost/$majHost/g" $chemin/backupFirefox.yml
		ansible-playbook $chemin/backupFirefox.yml
		rm $chemin/backupFirefox.yml
	else
		echo "Sur quel groupe voulez-vous exécuter le playbook ?"
		groupe=$(zenity --entry --text="Sur quel groupe voulez-vous exécuter le playbook ?")
		ret=$?
		if [ $ret == 1 ]
		then 
			return 99
		fi 
		cp $chemin/firefox.yml $chemin/backupFirefox.yml
		sed -i "s/ExampleHost/$groupe/g" $chemin/backupFirefox.yml
		ansible-playbook $chemin/backupFirefox.yml
		rm $chemin/backupFirefox.yml
	fi
}
function initial()
{	
	echo "Quel playbook voulez-vous exécuter ?"
	echo "[1] ajout d'un utilisateur"
	echo "[2] installation de firefox"
	echo "[99] Fin" 
	rep=$(zenity --list --column=numero --column=libellé "1" "ajout d'un utilisateur" "2" "firefox" "99" "menu principal" --text="Quel playbook voulez-vous exécuter?")
	ret=$?
	if [ $ret == 1 ]
	then
		return 99
	fi
	if [ $rep == 1  ]
	then 
		addUser
	fi 
	if [ $rep == 2 ] 
	then 
		firefox
	fi
	if [ $rep == 99 ]
	then 
		return 99
	fi	
}
initial 
