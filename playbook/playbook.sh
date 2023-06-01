#!/bin/bash 
chemin=$1/playbook
function addUser()
{
	echo "Sur quelle machine (alias) voulez-vous exécuter le playbook ?"
	host=$(zenity --entry --text="Sur quelle machine (alias) voulez-vous éxécuter le playbook?")
	#read host
	majHost=${host^^}
	echo "Quel est  le nom de l'utilisateur à ajouter ?" 
	name=$(zenity --entry --text="Quel est le nom de l'utilisateur à ajouter?")
	#read name 
	echo "Quel est le mot de passe de l'utilisateur ?"
	password=$(zenity --entry --text="Quel est le mot de passe de l'utilisateur $name?")
	#read password
	cp $chemin/adduser.yml $chemin/backup.yml
	sed -i "s/ExampleHost/$host/g" $chemin/backup.yml
	sed -i "s/ExampleUserName/$name/g" $chemin/backup.yml
	sed -i "s/ExampleUserPassword/$password/g" $chemin/backup.yml
	ansible-playbook $chemin/backup.yml
	rm $chemin/backup.yml
}
function firefox()
{
	echo "Voulez-vous déployer firefox sur une seule machine ou sur un groupe entier ? [Machine/Groupe]"
	reponse=$(zenity --entry --text="Voulez-vous déployer firefox sur une seule machine ou sur un groupe entier ? [Machine/Groupe]")
	majReponse=${reponse^^}
	if [ $majReponse == "MACHINE" -o $majReponse == "M" ]
	then
		echo "Sur quelle machine (alias) voulez-vous exécuter le playbook ?"
		host=$(zenity --entry --text="Sur quelle machine (alias) voulez-vous éxécuter le playbook?")
		majHost=${host^^}
		cp $chemin/firefox.yml $chemin/backupFirefox.yml
		sed -i "s/ExampleHost/$majHost/g" $chemin/backupFirefox.yml
		ansible-playbook $chemin/backupFirefox.yml
		rm $chemin/backupFirefox.yml
	else
		echo "Sur quel groupe voulez-vous exécuter le playbook ?"
		groupe=$(zenity --entry --text="Sur quel groupe voulez-vous exécuter le playbook ?")
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
	rep=$(zenity --list --column=numero --column=libellé "1" "ajout d'un utilisateur" "2" "firefox" "99" "exit" --text="Quel playbook voulez-vous exécuter?")
	#read rep
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
		echo ""
	fi	
}
initial 
