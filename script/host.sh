#!/bin/bash
# $1 est le groupe 
# $2 est l'ip de la machine 
# $3 est le chemin ou est le répertoire script222
echo "[$1]" >> $3/script/file/hosts
echo "$2" >> $3/script/file/hosts 
echo "" >> $3/script/file/hosts
