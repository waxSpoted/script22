#!/bin/bash
# $1 est le groupe 
# $2 est l'alias de la machine
# $3 est l'ip de la machine 
# $4 est le chemin du répertoire script222
echo "[$1]" >> $4/script/file/hosts
echo "$2 ansible_host=$3" >> $4/script/file/hosts 
echo "" >> $4/script/file/hosts
